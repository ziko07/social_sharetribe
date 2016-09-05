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

class UserNotification < ActiveRecord::Base
  include ActionView::Helpers
  belongs_to :person
  belongs_to :notification_sender,class_name: 'Person',foreign_key: 'sender'

  NOTIFICATION_TYPE = {
      post: 'Post',
      mention: 'Mention',
      wall: "Wall",
      post_like: 'Like Post',
      comment: 'Comment a Post',
      comment_like: 'Like Comment',
      other_wall: 'Others Wall',
      purchase_listing: 'Purchase Listing',
  }

  def self.send_notification(sender, reciever,object,event)
    if event == UserNotification::NOTIFICATION_TYPE[:post]
      link = "/#{object.person.username}/wall#wall_post_#{object.id}"
      description = "has updated his status"
    elsif event == UserNotification::NOTIFICATION_TYPE[:mention]
      link = "/#{object.person.username}/wall#wall_post_#{object.id}"
     description = "has mentioned you in his post"
    elsif event == UserNotification::NOTIFICATION_TYPE[:wall]
      link = "/#{object.person.username}/wall#wall_post_#{object.id}"
     description = "has posted on your wall"
    elsif event == UserNotification::NOTIFICATION_TYPE[:post_like]
      link = "/#{object.person.username}/wall#wall_comment_#{object.id}"
     description = "has like your post"
    elsif event == UserNotification::NOTIFICATION_TYPE[:comment]
      link = "/#{reciever.username}/wall#wall_comment_#{object.id}"
     description = "has comented on your post"
    elsif event == UserNotification::NOTIFICATION_TYPE[:comment_like]
     description = "has like your comment"
     link = "/#{object.person.username}/wall#comment-#{object.id}"
    elsif event == UserNotification::NOTIFICATION_TYPE[:purchase_listing]
      link = "/#{object.person.username}/wall#wall_post_#{object.id}"
     description = "has purchased a listing"
    end
    if reciever.id != sender.id
      reciever.user_notifications.create(sender: sender.id, content: description, link:link,event:event)
    end
  end
end
