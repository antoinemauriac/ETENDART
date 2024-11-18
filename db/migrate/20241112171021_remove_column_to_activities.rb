class RemoveColumnToActivities < ActiveRecord::Migration[7.0]
  def change
    remove_column :activities, :disable, :boolean
    remove_column :activities, :days, :text
  end
end
