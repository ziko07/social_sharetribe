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

class Report < ActiveRecord::Base
  belongs_to :reportable, :polymorphic => true
end
