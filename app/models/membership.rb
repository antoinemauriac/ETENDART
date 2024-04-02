class Membership < ApplicationRecord
  belongs_to :student
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

  validates :payment_method, inclusion: { in: %w[cheque cash hello_asso free] }, allow_nil: true

end
