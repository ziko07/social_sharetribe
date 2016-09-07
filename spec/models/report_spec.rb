# == Schema Information
#
# Table name: reports
#
#  id              :integer          not null, primary key
#  reportable_id   :string(255)
#  reportable_type :string(255)
#  reported_by     :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Report, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
