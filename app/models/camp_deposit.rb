class CampDeposit < ApplicationRecord

  belongs_to :manager, class_name: 'User'
  belongs_to :depositor, class_name: 'User'
  belongs_to :camp

  validates :cash_amount, numericality: { greater_than: 0 }, if: -> { cheque_amount.blank? || cheque_amount.zero? }
  validates :cheque_amount, numericality: { greater_than: 0 }, if: -> { cash_amount.blank? || cash_amount.zero? }
end
