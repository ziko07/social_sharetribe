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

class Privacy < ActiveRecord::Base
  belongs_to :person
end
