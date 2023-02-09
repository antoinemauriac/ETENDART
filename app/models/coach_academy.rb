class CoachAcademy < ApplicationRecord
  belongs_to :academy
  belongs_to :coach, class_name: 'User'
end
