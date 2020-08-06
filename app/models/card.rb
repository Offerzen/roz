class Card < ApplicationRecord
  belongs_to :team
  belongs_to :user, optional: true
  has_many   :transactions

end
