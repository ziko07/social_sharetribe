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
  include ActionView::Helpers
  belongs_to :person
  has_many :post_attachments, :as => :attachmentable, :dependent => :destroy
  has_many :post_comments, :as => :commentable, :dependent => :destroy
  has_many :likes, :as => :likeable, :dependent => :destroy
  has_many :reports, :as => :reportable, :dependent => :destroy

  POST_PURPOSE = {
      update_status: 'has update his status ',
      add_new_timelet: 'add new timelet',
      share_timelet: "share a timelet",
      purchase: 'purchase a timelet',
  }
  def mention_people(mention_params)
    mention_person = mention_params.present? ? JSON.parse(mention_params) : []
    mention_person.each do |mention|
      people = Person.find_by_username(mention['id'])
      if people.present?
        UserNotification.send_notification(self.person, people, self, UserNotification::NOTIFICATION_TYPE[:mention])
      end
    end
  end

end
