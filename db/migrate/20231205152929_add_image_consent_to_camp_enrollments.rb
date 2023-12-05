class AddImageConsentToCampEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_enrollments, :image_consent, :boolean, default: true
  end
end
