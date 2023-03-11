class RemoveStatusFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :status, :string
  end
end
