class RemoveFirstLoginFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :first_login, :boolean
  end
end
