class CreateBkashPayments < ActiveRecord::Migration
  def change
    create_table :bkash_payments do |t|
      t.integer :transaction_id
      t.integer :community_id
      t.string :status
      t.string :payer_id
      t.string :recipient_id
      t.string :mobile
      t.string :transaction_number
      t.string :currency
      t.integer :sum_cents
      t.timestamps null: false
    end
  end
end
