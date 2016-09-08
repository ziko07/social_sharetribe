# == Schema Information
#
# Table name: social_links
#
#  id         :integer          not null, primary key
#  person_id  :string(255)
#  facebook   :string(255)
#  twitter    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe SocialLink, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
