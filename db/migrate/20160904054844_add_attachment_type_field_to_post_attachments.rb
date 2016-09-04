class AddAttachmentTypeFieldToPostAttachments < ActiveRecord::Migration
  def change
    add_column :post_attachments, :attachment_type, :string
  end
end
