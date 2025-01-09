class AddStripeCustomerIdToParentProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :parent_profiles, :stripe_customer_id, :string
  end
end
