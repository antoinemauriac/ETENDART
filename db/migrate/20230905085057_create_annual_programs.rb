class CreateAnnualPrograms < ActiveRecord::Migration[7.0]
  def change
    create_table :annual_programs do |t|
      t.integer :start_year
      t.integer :end_year
      t.references :academy, null: false, foreign_key: true

      t.timestamps
    end
  end
end
