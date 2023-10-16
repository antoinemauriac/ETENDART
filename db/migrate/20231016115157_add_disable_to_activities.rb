class AddDisableToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :disable, :boolean, default: false
  end
end
