class AddForSellFieldToListings < ActiveRecord::Migration
  def change
    add_column :listings, :for_sell, :boolean
  end
end
