class AddUserToStudents < ActiveRecord::Migration[7.0]
  def change
    add_reference :students, :user, foreign_key: true #, null: false car on a déjà des étudiants en base
  end
end
