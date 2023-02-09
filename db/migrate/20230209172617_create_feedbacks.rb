class CreateFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :feedbacks do |t|
      t.string :content
      t.references :student, null: false, foreign_key: true
      t.references :coach, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
