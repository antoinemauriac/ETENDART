class AddBanishedToAcademies < ActiveRecord::Migration[7.0]
  def change
    add_column :academies, :banished, :boolean, default: false
  end
end
