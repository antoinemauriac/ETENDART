class ChangeColumnNameToActivities < ActiveRecord::Migration[7.0]
  def change
    rename_column :activities, :min_capcity, :min_capacity
  end
end
