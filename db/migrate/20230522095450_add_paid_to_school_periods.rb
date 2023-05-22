class AddPaidToSchoolPeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :school_periods, :paid, :boolean, default: false
  end
end
