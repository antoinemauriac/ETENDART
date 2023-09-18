class AddAnnualProgramToActivity < ActiveRecord::Migration[7.0]
  def change
    add_reference :activities, :annual_program, null: true, foreign_key: true
  end
end
