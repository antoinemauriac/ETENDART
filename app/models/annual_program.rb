class AnnualProgram < ApplicationRecord
  belongs_to :academy
  has_many :program_periods, dependent: :destroy
  accepts_nested_attributes_for :program_periods, reject_if: :all_blank, allow_destroy: true


  def has_started?
    false
  end
end
