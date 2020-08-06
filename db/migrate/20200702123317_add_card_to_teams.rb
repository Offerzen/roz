class AddCardToTeams < ActiveRecord::Migration[5.2]
  def change
		add_reference :teams, :card, foreign_key: true
  end
end
