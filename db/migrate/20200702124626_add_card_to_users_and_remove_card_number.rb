class AddCardToUsersAndRemoveCardNumber < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :card_number, :string

    add_reference :users, :card, foreign_key: true
  end
end
