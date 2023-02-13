class RemoveDay < ActiveRecord::Migration[7.0]
  def change
    drop_table :days
  end
end
