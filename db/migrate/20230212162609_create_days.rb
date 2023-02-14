class CreateDays < ActiveRecord::Migration[7.0]
  def change
    create_table :days do |t|
      t.string :day_of_week
      t.datetime :start_time
      t.datetime :end_time
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
