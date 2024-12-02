class AddColumnNewToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :new, :boolean, default: true
  end
end
