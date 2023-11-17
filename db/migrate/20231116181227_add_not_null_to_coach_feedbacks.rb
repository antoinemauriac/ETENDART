class AddNotNullToCoachFeedbacks < ActiveRecord::Migration[7.0]
  def change
    change_column_null :coach_feedbacks, :coach_id, false
    change_column_null :coach_feedbacks, :manager_id, false
  end
end
