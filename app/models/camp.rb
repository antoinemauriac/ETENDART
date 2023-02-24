class Camp < ApplicationRecord
  belongs_to :school_period
  has_many :activities

  has_many :camp_enrollments
  has_many :students, through: :camp_enrollments

  def students_count
    students.count
  end

end
