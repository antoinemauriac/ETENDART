class RemoveMaxCapacityToActivities < ActiveRecord::Migration[7.0]
  def change
    remove_column :activities, :max_capacity, :integer
    remove_column :activities, :min_capacity, :integer
  end
end
