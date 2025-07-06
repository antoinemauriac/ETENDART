class AddStripePriceIdToAnnualProgramEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_program_enrollments, :stripe_price_id, :string
  end
end
