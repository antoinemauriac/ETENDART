class Feedback < ApplicationRecord
  belongs_to :student
  belongs_to :coach, class_name: 'User', foreign_key: :coach_id
end
