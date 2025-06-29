class AddPaymentFieldsToAnnualPrograms < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_programs, :paid, :boolean, default: true
    add_column :annual_programs, :price, :integer, default: 0
  end
end
