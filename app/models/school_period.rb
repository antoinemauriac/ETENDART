class SchoolPeriod < ApplicationRecord
  belongs_to :academy
  has_many :camps
end
