class CreateBudgetCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_categories do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :budget_categories, :deleted_at
  end
end
