class RemvoveColumnDaysToActivities < ActiveRecord::Migration[7.0]
  def change
    remove_column :activities, :days, :text, array: true
  end
end
