class CreateCoachAcademies < ActiveRecord::Migration[7.0]
  def change
    create_table :coach_academies do |t|
      t.references :academy, null: false, foreign_key: true
      t.references :coach, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
