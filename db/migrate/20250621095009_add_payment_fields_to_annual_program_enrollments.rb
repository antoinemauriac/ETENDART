class AddPaymentFieldsToAnnualProgramEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_program_enrollments, :paid, :boolean, default: false
    add_column :annual_program_enrollments, :payment_date, :date
    add_column :annual_program_enrollments, :payment_method, :string
    add_reference :annual_program_enrollments, :receiver, null: true, foreign_key: { to_table: :users }
  end
end
