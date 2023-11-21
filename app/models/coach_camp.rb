class CoachCamp < ApplicationRecord
  belongs_to :camp
  belongs_to :coach, class_name: 'User'
end

# comment
