class AddAnnualToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :annual, :boolean, default: false
  end
end
