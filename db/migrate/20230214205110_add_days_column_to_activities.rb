class AddDaysColumnToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :days, :text
  end
end
