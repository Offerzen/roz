class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :role
      t.string :name
      t.string :email
      t.string :slack_user_id
      t.references :team, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :users, :role
    add_index :users, :email
    add_index :users, :deleted_at
  end
end
