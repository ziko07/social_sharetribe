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

class PostComment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :person
  has_many :likes, :as => :likeable,:dependent => :destroy
end
