class UpdateTransactionsToVersionTwo < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :investec_id, :string
    add_reference :transactions, :team, foreign_key: true
    add_reference :transactions, :budget_category, foreign_key: true
    add_column :transactions, :confirmation_state, :string, default: "uncomfirmed"
    add_reference :transactions, :confirmed_by, foreign_key: { to_table: :users }
    add_column :transactions, :description, :string
    add_column :transactions, :token, :string

    remove_reference :transactions, :merchant
  end
end
