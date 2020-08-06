require 'rails_helper'
require 'investec_open_api/client'

describe SyncTransactionsJob, type: :job do
  describe '#perform' do
    let!(:default_team) { create(:team, name: "Default", default: true, slack_id: 'hello', group: 'Testing' ) }
    let!(:team) { create(:team, name: "QA", slack_id: 'qa', group: 'Testing' ) }
    let!(:user) { create(:user, name: "Tester", slack_id: 'tester', role: "team_lead", team: team, email: "bob@bobber.com" ) }
    let!(:team_card) { create(:card, number: "4001", team: team) }
    let!(:user_card) { create(:card, number: "4002", user: user, team: default_team) }

    before do
      allow_any_instance_of(InvestecOpenApi::Client).to receive(:authenticate!).and_return(true)
      allow(Rails.application).to receive_message_chain(:routes, :url_helpers, :transaction_categorize_url).and_return 'http://fakeurl'
      allow(SlackService).to receive(:notify!)
      ENV["INVESTEC_API_ACCOUNT_ID"] = "test_account"
    end

    context "when the transactions don't exist on the database" do
      let(:transactions_card_for_team) {[
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "Now Now",
          "cardNumber" => "4001",
          "amount" => rand(500),
          "transactionDate"=>"2020-05-01",
          "postingDate"=>"2020-05-01",
          "valueDate"=>"2020-05-02",
          "actionDate"=>"2020-05-02"
        },
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "GitHub",
          "cardNumber" => "4001",
          "amount" => rand(500),
          "transactionDate"=>"2020-05-03",
          "postingDate"=>"2020-05-03",
          "valueDate"=>"2020-05-04",
          "actionDate"=>"2020-05-04"
        }
      ]}

      let(:transactions_card_for_user) {[
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "Now Now",
          "cardNumber" => "4002",
          "amount" => rand(500),
          "transactionDate"=>"2020-05-01",
          "postingDate"=>"2020-05-01",
          "valueDate"=>"2020-05-02",
          "actionDate"=>"2020-05-02"
        },
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "GitHub",
          "cardNumber" => "4002",
          "amount" => rand(500),
          "transactionDate"=>"2020-05-03",
          "postingDate"=>"2020-05-03",
          "valueDate"=>"2020-05-04",
          "actionDate"=>"2020-05-04"
        }
      ]}

      let(:transactions_unknown_card) {[
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "Now Now",
          "cardNumber" => "4003",
          "amount" => rand(500),
          "transactionDate"=>"2020-05-01",
          "postingDate"=>"2020-05-01",
          "valueDate"=>"2020-05-02",
          "actionDate"=>"2020-05-02"
        },
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "GitHub",
          "cardNumber" => "4003",
          "amount" => rand(500),
          "transactionDate"=>"2020-05-03",
          "postingDate"=>"2020-05-03",
          "valueDate"=>"2020-05-04",
          "actionDate"=>"2020-05-04"
        }
      ]}

      context "when transactions exist on the API" do
        before do
          allow_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).and_return(transactions_card_for_team.map { |t| InvestecOpenApi::Models::Transaction.from_api(t) })
        end

        it "enqueues the job correctly" do
          ActiveJob::Base.queue_adapter = :test
          expect { described_class.perform_later }.to have_enqueued_job
        end

        it "calls the API" do
          expect_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).with("test_account").once
          described_class.perform_now
        end

        it "creates new transactions" do
          expect{ described_class.perform_now }.to change(Transaction, :count).by(2)
        end
      end

      context "when there is a team associated to the card number" do
        before do
          allow_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).and_return(transactions_card_for_team.map { |t| InvestecOpenApi::Models::Transaction.from_api(t) })
        end

        it "assigns transactions to the team" do
          described_class.perform_now
          expect(team.transactions.count).to eq 2
          expect(user.transactions.count).to eq 0
        end
      end

      context "when there is a user associated to the card number" do
        before do
          allow_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).and_return(transactions_card_for_user.map { |t| InvestecOpenApi::Models::Transaction.from_api(t) })
        end

        it 'assigns transactions to the user' do
          described_class.perform_now
          expect(team.transactions.count).to eq 0
          expect(user.transactions.count).to eq 2
        end
      end

      context "when there is no owner associated to the card number" do
        before do
          allow_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).and_return(transactions_unknown_card.map { |t| InvestecOpenApi::Models::Transaction.from_api(t) })
        end

        it "creates new transactions" do
          expect{ described_class.perform_now }.to change(Transaction, :count).by(2)
        end

        it "links transactions to the default team" do
          described_class.perform_now
          expect(default_team.transactions.count).to eq(2)
        end

        it 'calls TransactionNotifier#notify_of_new_transaction!' do
          expect(TransactionNotifier).to receive(:notify_of_new_transaction!).exactly(2).times

          described_class.perform_now
        end
      end

      context "when transactions have already been created" do
        before do
          allow_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).and_return(transactions_card_for_team.map { |t| InvestecOpenApi::Models::Transaction.from_api(t) })
        end

        it "assigns transactions to the team" do
          described_class.perform_now

          # runs again later with the same result
          described_class.perform_now

          expect(team.transactions.count).to eq 2
        end

        it 'calls TransactionNotifier#notify_of_new_transaction!' do
          expect(TransactionNotifier).to receive(:notify_of_new_transaction!).exactly(2).times

          described_class.perform_now
        end
      end

      context 'when a similar Subscription transaction exists' do
        let!(:budget_category) { create(:budget_category, name: 'Subscriptions') }
        let!(:transaction2) { create(:transaction, amount: 50_000, description: 'Noodles!', budget_category: budget_category, card: team_card, team: team, date: DateTime.parse('01-01-2020 11:30 +0200')) }

        before do
          allow_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).and_return([InvestecOpenApi::Models::Transaction.from_api({
            "accountId" => '123',
            "type"=>"DEBIT",
            "status"=>"POSTED",
            "description"=> 'Noodles!',
            "cardNumber" => team_card.number,
            "amount" => 1_000_00,
            "postingDate"=>3.day.ago,
            "valueDate"=>1.day.ago,
            "actionDate"=>Time.zone.now
          })])
        end

        it 'does not call SlackService.notify!' do
          expect(SlackService).not_to receive(:notify!)

          described_class.perform_now
        end
      end
    end

    context 'when a transaction already exists on the database' do
      let(:transactions_card_for_team) {[
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "Now Now",
          "cardNumber" => "4001",
          "amount" => rand(500),
          "transactionDate"=>"2020-05-01",
          "postingDate"=>"2020-05-01",
          "valueDate"=>"2020-05-02",
          "actionDate"=>"2020-05-02"
        },
        {
          "accountId" => "1234",
          "type"=>"DEBIT",
          "status"=>"POSTED",
          "description"=> "GitHub",
          "cardNumber" => "4001",
          "amount" => 500,
          "transactionDate"=>"2020-05-03",
          "postingDate"=>"2020-05-03",
          "valueDate"=>"2020-05-04",
          "actionDate"=>"2020-05-04"
        }
      ]}

      before do
        create(:transaction, investec_id: "-500-GitHub-2020-05-03")
        allow_any_instance_of(InvestecOpenApi::Client).to receive(:transactions).and_return(transactions_card_for_team.map { |t| InvestecOpenApi::Models::Transaction.from_api(t) })
      end

      it "creates only unique transactions" do
        expect{ described_class.perform_now }.to change(Transaction, :count).by(1)
      end

      it "only calls the notifier once for new transactions" do
        expect(TransactionNotifier).to receive(:notify_of_new_transaction!).exactly(1).times

        described_class.perform_now
      end
    end
  end
end
