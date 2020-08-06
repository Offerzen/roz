class BudgetCategory < ApplicationRecord
  has_many :transactions
end
