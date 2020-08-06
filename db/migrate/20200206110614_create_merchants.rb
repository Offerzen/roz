class CreateMerchants < ActiveRecord::Migration[5.2]
  def change
    create_table :merchants do |t|
      t.string :name
      t.string :code
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :merchants, :name
    add_index :merchants, :code
    add_index :merchants, :deleted_at
  end
end
