class AddColumnSuperCategoryToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :super_category, :string
  end
end
