# == Schema Information
#
# Table name: user_notifications
#
#  id         :integer          not null, primary key
#  sender     :string(255)
#  person_id  :string(255)
#  content    :text(65535)
#  is_read    :boolean          default(FALSE)
#  link       :string(255)
#  event      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe UserNotification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
