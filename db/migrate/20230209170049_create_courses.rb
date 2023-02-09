class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.references :activity, null: false, foreign_key: true
      t.references :manager, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
