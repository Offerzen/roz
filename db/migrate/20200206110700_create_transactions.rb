class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :merchant, foreign_key: true
      t.monetize :amount
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :transactions, :deleted_at
  end
end
