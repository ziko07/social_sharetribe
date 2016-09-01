# == Schema Information
#
# Table name: post_comments
#
#  id               :integer          not null, primary key
#  commentable_id   :integer
#  commentable_type :string(255)
#  comment          :text(65535)
#  person_id        :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe PostComment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
