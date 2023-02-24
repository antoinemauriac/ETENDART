class SchoolPeriodEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :school_period
end
