# == Schema Information
#
# Table name: customer_offers
#
#  id           :integer          not null, primary key
#  community_id :integer
#  listing_id   :integer
#  status       :boolean          default(FALSE)
#  payer_id     :string(255)
#  recipient_id :string(255)
#  currency     :string(255)
#  amount       :float(24)
#  mobile       :string(255)
#  content      :text(65535)
#  read         :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe CustomerOffer, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
