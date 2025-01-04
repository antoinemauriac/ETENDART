class AddConsentToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :has_consent_for_photos, :boolean, default: false
  end
end
