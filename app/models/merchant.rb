class Merchant < ApplicationRecord
  belongs_to :budget_category, optional: true
  has_many :transactions
end
