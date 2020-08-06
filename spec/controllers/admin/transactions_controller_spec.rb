require 'rails_helper'

describe Admin::TransactionsController, type: :controller do
  let!(:team) { create(:team, slack_id: '12345', group: 'Test', name: 'Test') }
  let!(:current_user) { create(:user, slack_id: '12345', team: team, role: 'team_lead', name: 'Current User', email: 'currentuser@test.com', admin: true) }
  let!(:category1) { create(:budget_category, name: 'Category 1') }
  let!(:category2) { create(:budget_category, name: 'Category 2') }
  let!(:user) { create(:user, slack_id: '12345', team: team, role: 'team_lead', name: 'Bob Test', email: 'bob@test.com') }
  let!(:transaction1) { create(:transaction, team: team, amount_cents: 10_000_00, description: 'Transaction 1', budget_category: category1) }
  let!(:transaction2) { create(:transaction, team: team, amount_cents: 10_000_00, description: 'Transaction 1', budget_category: category2) }
  let!(:transaction3) { create(:transaction, team: team, amount_cents: 10_000_00, description: 'Transaction 1', budget_category: category1, user: user) }
  let!(:transaction3) { create(:transaction, team: team, amount_cents: 10_000_00, description: 'Transaction 1') }

  before do
    sign_in current_user
  end

  describe '#index' do
    context 'when viewing all transactions' do
      it 'returns all transactions' do
        get :index

        expect(assigns(:transactions).count).to eq 3
      end
    end

    context 'when viewing uncategorized transactions' do
      it 'returns all uncategorized transactions' do
        get :index, params: { scope: 'uncategorized' }

        expect(assigns(:transactions).count).to eq 1
      end
    end
  end

  describe '#update' do
    let!(:new_team) { create(:team, slack_id: '12345', group: 'Updated Group', name: 'Test') }
    let!(:new_user) { create(:user, slack_id: '12345', team: new_team, role: 'team_lead', name: 'Updated Bob', email: 'updatedbob@test.com') }
    let!(:new_category) { create(:budget_category, name: 'Category 3') }

    context 'with valid params' do
      let(:params) { { id: transaction1.id, user_id: new_user.id, team_id: new_team.id, budget_category_id: new_category.id } }

      it 'responds 200' do
        patch :update, params: params, xhr: true

        expect(response.status).to eq 200
      end

      it 'updates the transaction' do
        patch :update, params: params, xhr: true

        updated_transaction = transaction1.reload
        expect(updated_transaction.user).to eq new_user
        expect(updated_transaction.team).to eq new_team
        expect(updated_transaction.budget_category).to eq new_category
      end

      it 'updates the confirmed_by and confirmation state' do
        patch :update, params: params, xhr: true

        updated_transaction = transaction1.reload
        expect(updated_transaction.confirmed_by).to eq current_user
        expect(updated_transaction.confirmation_state).to eq 'confirmed'
      end

      it 'returns the group and transaction' do
        patch :update, params: params, xhr: true

        results = JSON.parse(response.body)
        expect(results['transaction']['id']).to eq transaction1.id
        expect(results['group']).to eq 'Updated Group'
      end
    end
  end
end
