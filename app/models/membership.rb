class Membership < ApplicationRecord
  belongs_to :student
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true
  belongs_to :academy, optional: true

  validates :payment_method, inclusion: { in: %w[cash cheque hello_asso offert virement pass] }, allow_nil: true

  scope :paid, -> { where(status: true) }
  scope :unpaid, -> { where(status: false) }

  # # methode pour retrouver les memebrships en fonction de la start_year

  # def self.memberships_by_year(year)
  #   where(start_year: year)
  # end

end
