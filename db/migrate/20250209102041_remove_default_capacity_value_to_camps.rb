class RemoveDefaultCapacityValueToCamps < ActiveRecord::Migration[7.0]
  def change
    change_column_default :camps, :capacity, nil
  end
end
