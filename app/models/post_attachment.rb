# == Schema Information
#
# Table name: post_attachments
#
#  id                  :integer          not null, primary key
#  attachmentable_id   :integer
#  attachmentable_type :string(255)
#  attachment          :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  attachment_type     :string(255)
#

class PostAttachment < ActiveRecord::Base
  belongs_to :attachmentable, :polymorphic => true
  mount_uploader :attachment, AttachmentUploader
end
