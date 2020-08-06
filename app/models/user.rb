class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :transactions
  has_many :cards
  belongs_to :team

  ROLES = %W[team_lead team_member]
  validates :role, inclusion: ROLES

  validates :team, :slack_id, :email, presence: true

  has_many :transactions

  def humanized_role
    role&.humanize
  end
end
