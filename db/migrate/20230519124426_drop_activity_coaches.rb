class DropActivityCoaches < ActiveRecord::Migration[7.0]
  def change
    drop_table :activity_coaches
  end
end
