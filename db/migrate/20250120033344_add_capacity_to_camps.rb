class AddCapacityToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :capacity, :integer, default: 20
    add_column :camps, :waitlist_capacity, :integer, default: 5
  end
end
