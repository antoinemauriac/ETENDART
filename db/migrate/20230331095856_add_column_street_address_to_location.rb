class AddColumnStreetAddressToLocation < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :street_address, :string
  end
end
