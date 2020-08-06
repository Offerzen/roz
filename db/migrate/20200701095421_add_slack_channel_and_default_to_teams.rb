class AddSlackChannelAndDefaultToTeams < ActiveRecord::Migration[5.2]
  def change
		add_column :teams, :slack_channel_id, :string
		add_column :teams, :default, :bool, default: false
  end
end
