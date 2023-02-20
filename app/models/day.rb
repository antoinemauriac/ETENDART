class Day < ApplicationRecord
  belongs_to :activity
  attr_accessor :start_time_Monday, :end_time_Monday, :start_time_Tuesday, :end_time_Tuesday, :start_time_Wednesday, :end_time_Wednesday, :start_time_Thursday, :end_time_Thursday, :start_time_Friday, :end_time_Friday

  after_save :update_day_times

  private

  def update_day_times
    days = %w[Monday Tuesday Wednesday Thursday Friday]
    days.each do |day|
      start_time = public_send("start_time_#{day}")
      end_time = public_send("end_time_#{day}")
      if start_time.present? && end_time.present?
        day_time = day_times.find_or_initialize_by(day_of_week: day)
        day_time.update(start_time: start_time, end_time: end_time)
      end
    end
  end
end
