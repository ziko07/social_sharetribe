class CreatePostAttachments < ActiveRecord::Migration
  def change
    create_table :post_attachments do |t|
      t.integer :attachmentable_id
      t.string :attachmentable_type
      t.string :attachment

      t.timestamps null: false
    end
  end
end
