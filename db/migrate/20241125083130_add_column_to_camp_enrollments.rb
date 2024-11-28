class AddColumnToCampEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_enrollments, :payment_date, :date
    add_column :camp_enrollments, :payment_method, :string
    add_reference :camp_enrollments, :receiver, foreign_key: { to_table: :users }
  end
end
