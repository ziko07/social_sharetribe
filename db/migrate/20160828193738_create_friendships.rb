class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.string :friendable_id
      t.string :friend_id
      t.string :blocker_id
      t.boolean :pending, :default => true
    end

    add_index :friendships, [:friendable_id, :friend_id], :unique => true
  end

  def self.down
    drop_table :friendships
  end
end
