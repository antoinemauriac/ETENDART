class ProgramPeriod < ApplicationRecord
  belongs_to :annual_program

  validates :start_date, presence: true
  validates :end_date, presence: true
  before_save :start_date_before_end_date

  def start_date_before_end_date
    start_date < end_date
  end
end
