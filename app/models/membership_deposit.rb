class MembershipDeposit < ApplicationRecord

  belongs_to :manager, class_name: 'User'
  belongs_to :depositor, class_name: 'User'

  validates :cash_amount, presence: true, if: -> { cheque_amount.blank? }
  validates :cheque_amount, presence: true, if: -> { cash_amount.blank? }
end
