class AddGroupToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :group, :string
  end
end
