class Transaction < ApplicationRecord
  has_paper_trail
  
  belongs_to :user, optional: true
  belongs_to :team, optional: true
  belongs_to :card, optional: true
  belongs_to :budget_category, optional: true
  belongs_to :confirmed_by, optional: true, class_name: 'User'
  monetize :amount_cents

  after_create :generate_token

  def generate_token
    update(token: SecureRandom.hex(64))
  end

  def confirmed?
    confirmation_state == "confirmed"
  end
end
