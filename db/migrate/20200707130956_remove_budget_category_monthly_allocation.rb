class RemoveBudgetCategoryMonthlyAllocation < ActiveRecord::Migration[5.2]
  def change
    drop_table :budget_category_monthly_allocations
  end
end
