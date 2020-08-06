class TransactionNotifier
  def initialize(team:, user:, transaction:)
    @team = team
    @user = user
    @transaction = transaction
  end

  def self.notify_of_new_transaction!(team:, user:, transaction:)
    new(team: team, user: user, transaction: transaction).notify_of_new_transaction!
  end

  def notify_of_new_transaction!
    SlackService.notify!(team.slack_id, nil, transaction_blocks)
  end

  private

  attr_reader :team, :user, :transaction

  def card
    @_card ||= transaction.card
  end

  def transaction_blocks
    [
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: "<!channel> *Someone spent some money on #{user.present? ? user.name.possessive : 'the team'} card*"
        }
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: "Amount spent: *#{transaction.amount.abs.format(symbol: 'R')}*\nDescription: *#{transaction.description}*\nDate: *#{transaction.date.strftime('%-d %B %Y %I:%M%p')}*"
        }
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: "*Was it you?* Click to classify your purchase"
        }
      },
      {
        type: "actions",
        elements: [
          {
            type: "button",
            text: {
              type: "plain_text",
              text: "It was me",
              emoji: false
            },
            url: Rails.application.routes.url_helpers.transaction_categorize_url(
              transaction,
              token: transaction.token,
              host: ENV["DOMAIN"],
              protocol: ENV["PROTOCOL"]
            )
          }
        ]
      }
    ]
  end

  def transaction_message
    "<!channel> *Someone spent some money on #{user.present? ? user.name.possessive : 'the team'} card*\n\n \
    Amount spent: *#{transaction.amount.abs.format(symbol: 'R')}*\n \
    Description: *#{transaction.description}*\n \
    Date: *#{transaction.date.strftime('%-d %B %Y %I:%M%p')}* \
    *Was it you?* Click to classify your purchase...".gsub('  ', '')
  end

  def transaction_card
    card.team.name
  end
end
