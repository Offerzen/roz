class BudgetCategoryMonthlyAllocation < ApplicationRecord
  belongs_to :team
  belongs_to :budget_category
  monetize :amount_cents
end
