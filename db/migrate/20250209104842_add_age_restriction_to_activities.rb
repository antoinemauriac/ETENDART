class AddAgeRestrictionToActivities < ActiveRecord::Migration[7.0]
  def up
    add_column :activities, :age_restricted, :boolean, default: false
    add_column :activities, :min_age, :integer
    add_column :activities, :max_age, :integer

    # Mise à jour des enregistrements existants
    Activity.update_all(age_restricted: false)

    # Suppression du défaut et ajout de la contrainte null: false pour `age_restricted`
    change_column_default :activities, :age_restricted, nil
    change_column_null :activities, :age_restricted, false
  end

  def down
    remove_column :activities, :age_restricted
    remove_column :activities, :min_age
    remove_column :activities, :max_age
  end
end
