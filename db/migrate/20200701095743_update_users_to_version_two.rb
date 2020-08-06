class UpdateUsersToVersionTwo < ActiveRecord::Migration[5.2]
  def change
  	rename_column :users, :slack_user_id, :slack_id
  end
end
