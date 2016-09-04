# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  person_id    :string(255)
#  post_to_id   :string(255)
#  description  :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  purpose      :string(255)
#  update_time  :integer
#  listings_ids :string(255)
#

class Post < ActiveRecord::Base
  belongs_to :person
  has_many :post_attachments,:as => :attachmentable,:dependent => :destroy
  has_many :post_comments,:as => :commentable,:dependent => :destroy
  has_many :likes,:as => :likeable,:dependent => :destroy
end
