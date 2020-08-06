class AddInvestecPostingDateToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :investec_posting_date, :datetime
  end
end
