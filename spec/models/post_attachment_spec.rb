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

require 'rails_helper'

RSpec.describe PostAttachment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
