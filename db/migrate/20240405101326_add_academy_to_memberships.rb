class AddAcademyToMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :memberships, :academy_id, :integer
  end
end
