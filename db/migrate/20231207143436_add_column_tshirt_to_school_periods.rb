class AddColumnTshirtToSchoolPeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :school_periods, :tshirt, :boolean, default: false
  end
end
