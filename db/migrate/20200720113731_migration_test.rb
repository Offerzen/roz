class MigrationTest < ActiveRecord::Migration[5.2]
  def change
    create_table :migration_test do |t|
      t.string :test
    end
  end
end
