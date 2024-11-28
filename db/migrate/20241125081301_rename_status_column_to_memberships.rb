class RenameStatusColumnToMemberships < ActiveRecord::Migration[7.0]
  def change
    rename_column :memberships, :status, :paid
  end
end
