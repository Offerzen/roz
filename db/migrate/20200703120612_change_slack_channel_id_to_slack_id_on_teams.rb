class ChangeSlackChannelIdToSlackIdOnTeams < ActiveRecord::Migration[5.2]
  def change
    rename_column :teams, :slack_channel_id, :slack_id
  end
end
