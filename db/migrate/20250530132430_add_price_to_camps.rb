class AddPriceToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :price, :integer, default: 0, null: false
  end
end
