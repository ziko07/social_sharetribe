class AddCoverPhotoFieldToPeople < ActiveRecord::Migration
  def change
    add_column :people, :cover_photo, :string
  end
end
