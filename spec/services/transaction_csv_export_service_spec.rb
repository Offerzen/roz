require 'rails_helper'

describe TransactionCsvExportService do
  describe '#generate_csv!' do
    let!(:team) { create(:team, slack_id: '12345', group: 'Test', name: 'Test') }
    let!(:category1) { create(:budget_category, name: 'Category 1') }
    let!(:category2) { create(:budget_category, name: 'Category 2') }
    let!(:user) { create(:user, slack_id: '12345', team: team, role: 'team_lead', name: 'Bob Test', email: 'bob@test.com') }
    let!(:transaction1) { create(:transaction, team: team, amount_cents: 10_000_00, description: 'Transaction 1', budget_category: category1, date: Date.current) }
    let!(:transaction2) { create(:transaction, team: team, amount_cents: 10_000_00, description: 'Transaction 2', budget_category: category2, date: Date.current) }
    let!(:transaction3) { create(:transaction, team: team, amount_cents: 10_000_00, description: 'Transaction 3', budget_category: category1, user: user, date: Date.current) }
    let(:all_transactions) { [transaction1, transaction2, transaction3] }

    let(:expected_cash_report_csv) do
      headers = ["Effective Date", "SERVICE FEE", "AMOUNT", "DESCRIPTION", "REFERENCE", "BALANCE", "MAPPING", "Team", "Group"].join(',')
      body = all_transactions.map do |transaction|
        "#{transaction.date.strftime('%Y/%m/%d')},,#{transaction.amount},#{transaction.description},,,#{transaction.budget_category.name},#{transaction.team.name},#{transaction.team.group}"
      end.join("\n")

      "#{headers}\n#{body}\n"
    end

    let(:expected_sage_report_csv) do
      headers = ["Date", "Description", "Amount"].join(',')
      body = all_transactions.map do |transaction|
        "#{transaction.date.strftime('%Y/%m/%d')},#{transaction.description},#{transaction.amount}"
      end.join("\n")

      "#{headers}\n#{body}\n"
    end

    context 'when the format is cash_report' do
      it 'creates and returns a new CSV string' do
        result_csv = described_class.generate_csv!([transaction1, transaction2, transaction3], :cash_report)

        expect(result_csv).to eq expected_cash_report_csv
      end
    end

    context 'when the format is sage_report' do
      it 'creates and returns a new CSV string' do
        result_csv = described_class.generate_csv!([transaction1, transaction2, transaction3], :sage_report)

        expect(result_csv).to eq expected_sage_report_csv
      end
    end
  end
end
