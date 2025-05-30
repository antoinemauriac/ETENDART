class CreateProgramPeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :program_periods do |t|
      t.date :start_date
      t.date :end_date
      t.references :annual_program, null: false, foreign_key: true

      t.timestamps
    end
  end
end
