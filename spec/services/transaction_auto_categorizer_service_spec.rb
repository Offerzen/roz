require 'rails_helper'

describe TransactionAutoCategorizerService do
  describe '#categorize!' do
    let!(:team) { create(:team, slack_id: '12345', group: 'Test', name: 'Test') }
    let!(:team2) { create(:team, slack_id: '4568', group: 'Matcher', name: 'Like and Subscribe') }
    let!(:user) { create(:user, slack_id: '12345', team: team, role: 'team_member', name: 'Bob Test', email: 'bob@test.com') }
    let!(:user2) { create(:user, slack_id: '5553', team: team, role: 'team_member', name: 'Rob Best', email: 'rob@best.com') }
    let!(:card) { create(:card, team: team, number: '111232') }
    let!(:card2) { create(:card, team: team2, user: user2, number: '5541355') }
    let!(:category1) { create(:budget_category, name: 'Subscriptions') }
    let!(:category2) { create(:budget_category, name: 'Food & Snacks') }
    let!(:synced_transaction) { create(:transaction, card: card, team: team, amount_cents: 1_000_00, description: 'GitHub', date: Date.current) }

    context 'when there is a similar Subscription transaction' do
      let!(:transaction1) { create(:transaction, card: card, team: team2, amount_cents: 3_000_00, description: 'GitHub', budget_category: category1, user: user, date: 1.days.ago) }

      it 'finds a match' do
        match = TransactionAutoCategorizerService.categorize!(synced_transaction)

        expect(match).to be_present
        expect(match[:team]).to eq transaction1.team
        expect(match[:user]).to eq transaction1.user
      end
      
      it 'updates transaction team and user to match' do
        match = TransactionAutoCategorizerService.categorize!(synced_transaction)

        expect(synced_transaction.team).to eq transaction1.team
        expect(synced_transaction.user).to eq transaction1.user
        expect(synced_transaction.confirmation_state).to eq 'auto-categorized'
      end
    end

    context 'when there is no similar Subscription transaction' do
      let!(:transaction2) { create(:transaction, card: card, team: team2, amount_cents: 2_000_00, description: 'GitHub sub', budget_category: category2, user: user, date: 2.days.ago) }
      
      it 'finds no match' do
        match = TransactionAutoCategorizerService.categorize!(synced_transaction)

        expect(match).to be_nil
      end
      
      it 'updates transaction team and user to match' do
        match = TransactionAutoCategorizerService.categorize!(synced_transaction)

        expect(synced_transaction.team).to eq team
        expect(synced_transaction.user).to eq nil
        expect(synced_transaction.confirmation_state).to eq 'unconfirmed'
      end
    end
  end
end
