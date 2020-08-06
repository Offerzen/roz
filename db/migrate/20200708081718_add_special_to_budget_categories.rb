class AddSpecialToBudgetCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_categories, :special, :bool, default: false
  end
end
