class CreateBudgetCategoryMonthlyAllocations < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_category_monthly_allocations do |t|
      t.references :team, foreign_key: true
      t.references :budget_category, foreign_key: true
      t.monetize :amount
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :budget_category_monthly_allocations, :deleted_at
  end
end
