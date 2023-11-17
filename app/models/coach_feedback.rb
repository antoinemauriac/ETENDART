class CoachFeedback < ApplicationRecord
  belongs_to :coach, class_name: 'User', foreign_key: :coach_id
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id
end
