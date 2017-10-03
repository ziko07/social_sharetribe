# == Schema Information
#
# Table name: bkash_payments
#
#  id                 :integer          not null, primary key
#  transaction_id     :integer
#  community_id       :integer
#  status             :string(255)
#  payer_id           :string(255)
#  recipient_id       :string(255)
#  mobile             :string(255)
#  transaction_number :string(255)
#  currency           :string(255)
#  sum_cents          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe BkashPayment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
