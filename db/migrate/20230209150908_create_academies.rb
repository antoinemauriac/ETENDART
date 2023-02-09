class CreateAcademies < ActiveRecord::Migration[7.0]
  def change
    create_table :academies do |t|
      t.string :name
      t.references :manager, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
