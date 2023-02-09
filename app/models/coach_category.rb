class CoachCategory < ApplicationRecord
  belongs_to :category
  belongs_to :coach, class_name: 'User'
end
