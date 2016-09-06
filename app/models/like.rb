# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  likeable_id   :integer
#  likeable_type :string(255)
#  person_id     :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Like < ActiveRecord::Base
  belongs_to :person
  belongs_to :likeable, :polymorphic => true

  after_create :send_notification

  def send_notification
    if self.likeable.class.to_s == 'Post'
      UserNotification.send_notification(self.person, self.likeable.person, self.likeable, UserNotification::NOTIFICATION_TYPE[:post_like])
    else
      UserNotification.send_notification(self.person, self.likeable.person, self.likeable, UserNotification::NOTIFICATION_TYPE[:comment_like])
    end
  end
end
