class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.string :name
      t.text :days
      t.references :camp, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :coach, null: false, foreign_key: { to_table: :users }
      t.integer :min_capcity
      t.integer :max_capacity

      t.timestamps
    end
  end
end
