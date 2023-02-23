class AddColumnsToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :city, :string
    add_column :locations, :zipcode, :string
    add_column :locations, :country, :string
    add_column :locations, :lat, :decimal, precision: 9, scale: 6, null: true
    add_column :locations, :lng, :decimal, precision: 9, scale: 6, null: true
  end
end
