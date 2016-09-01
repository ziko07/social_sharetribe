class CreateStripePayments < ActiveRecord::Migration
  def change
    create_table :stripe_payments do |t|
      t.integer :transaction_id
      t.integer :community_id
      t.string :status
      t.string :payer_id
      t.string :recipient_id
      t.string :currency
      t.string :customer_id
      t.integer :sum_cents
      t.timestamps null: false
    end
  end
end
