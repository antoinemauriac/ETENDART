class ChangeCoachIdToAllowNullInActivities < ActiveRecord::Migration[7.0]
  def change
    change_column :activities, :coach_id, :bigint, null: true
  end
end
