class DropOrdersTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :orders
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
