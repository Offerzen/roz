require 'sidekiq-scheduler'
require 'investec_open_api/client'

class SyncTransactionsJob < ApplicationJob
  def perform
    api = InvestecOpenApi::Client.new
    api.authenticate!

    investec_transactions = api.transactions(ENV['INVESTEC_API_ACCOUNT_ID'])
    investec_transactions.each do |investec_transaction|
      sync_transaction(investec_transaction)
    end
  end

  def sync_transaction(investec_transaction)
    card = Card.find_by(number: investec_transaction.card_number)
    team = card&.team || Team.find_by(default: true)
    user = card&.user

    amount = Money.new(investec_transaction[:amount], "ZAR")

    transaction = Transaction.find_or_initialize_by(investec_id: investec_transaction[:id])

    transaction.assign_attributes(
      amount: amount,
      description: investec_transaction[:description],
      card: card,
      date: investec_transaction[:date],
      user: user,
      team: team
    )

    new_record = transaction.new_record?
    transaction.save!

    if amount < 0 && new_record
      auto_categorize_and_notify_of_new_transaction(team: team, user: user, transaction: transaction)
    end
  end

  def auto_categorize_and_notify_of_new_transaction(team:, user:, transaction:)
    auto_categorize_match = auto_categorize_transaction!(transaction)

    TransactionNotifier.notify_of_new_transaction!(team: team, user: user, transaction: transaction) if auto_categorize_match.nil? && ENV['SLACK_NOTIFICATIONS_ENABLED'] == "true"
  end

  def auto_categorize_transaction!(transaction)
    TransactionAutoCategorizerService.categorize!(transaction)
  end
end
