class AddPriceToSchoolPeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :school_periods, :price, :integer, default: 0, null: false
  end
end
