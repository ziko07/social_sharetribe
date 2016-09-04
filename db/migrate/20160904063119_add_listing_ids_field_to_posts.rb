class AddListingIdsFieldToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :listings_ids, :string
  end
end
