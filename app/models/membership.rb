class Membership < ApplicationRecord
  belongs_to :student
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true
  belongs_to :academy, optional: true

  validates :payment_method, inclusion: { in: %w[cash cheque hello_asso offert virement pass] }, allow_nil: true

  scope :paid, -> { where(status: true) }
  scope :unpaid, -> { where(status: false) }

  def self.with_all_course_enrollments_present_false
    joins(student: { course_enrollments: :course })
      .where('courses.ends_at < ?', Date.current)
      .group('memberships.id')
      .having('bool_and(course_enrollments.present = false)')
  end
end
