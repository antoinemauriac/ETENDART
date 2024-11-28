class CampEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :camp
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", nil].freeze
  validates :payment_method, inclusion: { in: Membership::PAYMENT_METHODS }

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  scope :banished, -> { where(banished: true) }

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  def camp_starts_at
    camp.starts_at
  end

end
