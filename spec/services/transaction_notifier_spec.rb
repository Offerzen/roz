require 'rails_helper'

describe TransactionNotifier do
  describe '#notify_of_new_service!' do
    context 'when there is no user' do
      let!(:team) { create(:team, name: "QA", slack_id: '12345', group: 'test') }
      let!(:user) { create(:user, name: 'bob', email: 'bob@test.com', role: 'team_member', team: team, slack_id: '12345') }
      let!(:team_card) { create(:card, number: "4001", team: team) }
      let!(:transaction) { create(:transaction, amount: 50_000, description: 'Noodles!', card: team_card, date: DateTime.parse('01-01-2020 11:30 +0200')) }
      
      before do
        allow(SlackService).to receive(:notify!)
      end

      context 'when there is no similar Subscription transaction' do
        it 'calls SlackService.notify!' do

          expected_block = [
            {
              :text => {
                :text=>"<!channel> *Someone spent some money on the team card*",
                :type=>"mrkdwn"
              },
              :type=>"section"
            },
            {
              :text=> {
                :text=> "Amount spent: *#{transaction.amount.abs.format(symbol: 'R')}*\nDescription: *#{transaction.description}*\nDate: *#{transaction.date.strftime('%-d %B %Y %I:%M%p')}*",
                :type=>"mrkdwn"
              },
              :type=>"section"
            },
            {
              :text => {
                :text=>"*Was it you?* Click to classify your purchase",
                :type=>"mrkdwn"
              },
              :type=>"section"
            },
            {
              :elements=>[
                {
                  :text => {
                    :emoji=>false,
                    :text=>"It was me",
                    :type=>"plain_text"
                  },
                  :type=>"button",
                  :url=> Rails.application.routes.url_helpers.transaction_categorize_url(transaction, token: transaction.token, host: ENV["DOMAIN"], protocol: ENV["PROTOCOL"])
                }
              ],
              :type=>"actions"
            }
          ]

          expect(SlackService).to receive(:notify!).with(
            '12345',
            nil,
            expected_block
          )

          described_class.notify_of_new_transaction!(team: team, user: nil, transaction: transaction)
        end
      end
    end
  end
end
