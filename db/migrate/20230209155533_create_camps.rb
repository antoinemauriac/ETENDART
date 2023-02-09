class CreateCamps < ActiveRecord::Migration[7.0]
  def change
    create_table :camps do |t|
      t.string :name
      t.date :starts_at
      t.date :ends_at
      t.references :school_period, null: false, foreign_key: true

      t.timestamps
    end
  end
end
