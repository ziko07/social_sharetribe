class AddPurposeFieldToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :purpose, :string
    add_column :posts, :update_time, :integer
  end
end
