# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  person_id   :string(255)
#  post_to_id  :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  purpose     :string(255)
#  update_time :integer
#

require 'rails_helper'

RSpec.describe Post, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
