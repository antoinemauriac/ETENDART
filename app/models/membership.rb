class Membership < ApplicationRecord
  belongs_to :student
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true
  belongs_to :academy, optional: true

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", nil].freeze
  PAYMENT_METHODS_WITH_RECEIVER = ["cash", "cheque", "offert"].freeze
  validates :payment_method, inclusion: { in: Membership::PAYMENT_METHODS }
  PRICE = 15

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  # MÉTHODE QUI RENVOIE LES MEMBERSHIPS A PRIORI NON EXIGIBLES
  def self.with_all_course_enrollments_present_false
    joins(student: { course_enrollments: :course })
      .where('courses.ends_at BETWEEN ? AND ?', Date.new(2024, 4, 7), Date.current)
      .group('students.id', 'memberships.id')
      .having('bool_and(course_enrollments.present = false)')
      .pluck('students.id', 'memberships.id')
      .to_h
  end

  # SUPPRESSION DES MEMBERSHIPS A PRIORI NON EXIGIBLES SI L'ELEVE N'A PAS DE COURS FUTUR
  # Membership.with_all_course_enrollments_present_false.each do |student_id, membership_id|
  #   student = Student.find(student_id)
  #   membership = Membership.find(membership_id)
  #   if student.courses.where('starts_at > ?', Date.current).empty?
  #     membership.destroy
  #   end
  # end
end
