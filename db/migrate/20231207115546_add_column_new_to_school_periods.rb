class AddColumnNewToSchoolPeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :school_periods, :new, :boolean, default: true
  end
end
