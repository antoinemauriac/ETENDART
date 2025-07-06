class AddStripePriceIdToAnnualPrograms < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_programs, :stripe_price_id, :string
  end
end
