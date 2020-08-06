class Team < ApplicationRecord
  has_many   :users
  has_many   :cards
  has_many   :transactions

  validates :name, :slack_id, :group, presence: true
end
