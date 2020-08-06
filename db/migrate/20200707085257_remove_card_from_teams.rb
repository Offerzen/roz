class RemoveCardFromTeams < ActiveRecord::Migration[5.2]
  def change
    remove_column :teams, :card_id
  end
end
