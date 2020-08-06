class AddCardNumberToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :card_number, :string
    add_index :users, :card_number
  end
end
