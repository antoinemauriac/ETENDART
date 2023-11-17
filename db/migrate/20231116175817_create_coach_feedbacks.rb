class CreateCoachFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :coach_feedbacks do |t|
      t.text :content
      t.references :coach, foreign_key: { to_table: :users }
      t.references :manager, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
