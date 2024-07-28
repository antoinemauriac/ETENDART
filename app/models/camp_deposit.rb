class CampDeposit < ApplicationRecord

  belongs_to :camp
  belongs_to :manager, class_name: 'User'

  validates :amount, presence: true
end
