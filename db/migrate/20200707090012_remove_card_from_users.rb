class RemoveCardFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :card_id
  end
end
