class CreateStripeAccounts < ActiveRecord::Migration
  def change
    create_table :stripe_accounts do |t|
      t.string :person_id
      t.integer :community_id
      t.string :account_id
      t.text :token
      t.text :public_key
      t.text :secret_key
      t.string :state
      t.string :country
      t.boolean :active, default: false
      t.timestamps null: false
    end
  end
end
