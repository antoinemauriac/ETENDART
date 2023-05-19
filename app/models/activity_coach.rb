class ActivityCoach < ApplicationRecord
  belongs_to :activity
  belongs_to :coach, class_name: 'User', foreign_key: :coach_id
end
