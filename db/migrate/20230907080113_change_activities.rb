class ChangeActivities < ActiveRecord::Migration[7.0]
  def change
    change_column_null :activities, :camp_id, true
  end
end
