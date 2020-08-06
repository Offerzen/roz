class RemoveMigrationTest < ActiveRecord::Migration[5.2]
  def change
    drop_table :migration_test
  end
end
