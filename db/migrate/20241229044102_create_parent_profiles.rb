class CreateParentProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :parent_profiles do |t|
      t.string :gender
      t.string :relationship_to_child
      t.string :phone_number
      t.string :address
      t.string :zipcode
      t.string :city
      t.boolean :has_valid_rgpd
      t.boolean :has_newsletter

      t.timestamps
      t.references :user, null: false, foreign_key: { to_table: :users }
    end

  end
end
