class AddVerificationDetailsToStripeAccounts < ActiveRecord::Migration
  def change
    add_column :stripe_accounts, :verification_details, :text
  end
end
