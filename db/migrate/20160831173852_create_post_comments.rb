class CreatePostComments < ActiveRecord::Migration
  def change
    create_table :post_comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.text :comment
      t.string :person_id

      t.timestamps null: false
    end
  end
end
