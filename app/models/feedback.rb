class Feedback < ApplicationRecord
  belongs_to :student
  belongs_to :coach, class_name: 'User', foreign_key: :coach_id


  # def self.last_five(manager)
  #   joins(student: [:academies])
  #     .where(academies: { manager_id: manager.id })
  #     .order(created_at: :desc)
  #     .limit(5)
  #     .distinct
  # end

  def self.last_five(academy)
    joins(student: :academies)
      .where(created_at: 10.week.ago..Time.now)
      .where(academies: { id: academy.id })
      .order(created_at: :desc)
      .limit(5)
      .distinct
  end
end
