class CreateCustomerOffers < ActiveRecord::Migration
  def change
    create_table :customer_offers do |t|
      t.integer :community_id
      t.integer :listing_id
      t.boolean :status, default: false
      t.string :payer_id
      t.string :recipient_id
      t.string :currency
      t.float :amount
      t.string :mobile
      t.text :content
      t.boolean :read, default: false
      t.timestamps null: false
    end
  end
end
