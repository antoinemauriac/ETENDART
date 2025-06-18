class MigratePricesFromSchoolPeriodsToCamps < ActiveRecord::Migration[7.0]
  def up
    # Copy price from school_period to all its camps
    SchoolPeriod.includes(:camps).each do |school_period|
      school_period.camps.update_all(price: school_period.price || 0)
    end
  end

  def down
    # Reset all camp prices to 0
    Camp.update_all(price: 0)
  end
end
