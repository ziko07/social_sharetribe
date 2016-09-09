# == Schema Information
#
# Table name: privacies
#
#  id            :integer          not null, primary key
#  person_id     :string(255)
#  auto_follower :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe Privacy, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
