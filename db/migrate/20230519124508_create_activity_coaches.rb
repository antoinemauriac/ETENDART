class CreateActivityCoaches < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_coaches do |t|
      t.references :coach, null: false, foreign_key: { to_table: :users }
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
