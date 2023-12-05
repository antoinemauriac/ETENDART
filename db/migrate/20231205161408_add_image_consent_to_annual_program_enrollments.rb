class AddImageConsentToAnnualProgramEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_program_enrollments, :image_consent, :boolean, default: true
  end
end
