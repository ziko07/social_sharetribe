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

class BkashPayment < ActiveRecord::Base
  attr_accessible :currency, :transaction_id, :community_id, :status, :payer_id, :recipient_id, :mobile,:transaction_number, :sum_cents

  monetize :sum_cents, allow_nil: true, with_model_currency: :currency

  def sum_exists?
    !sum_cents.nil?
  end

  def total_sum
    sum
  end

  def paid!
    update_attribute(:status, 'preauthorize')
    # transaction = Transaction.find_by_id(transaction_id)
    # if transaction.present?
    #   transaction.update_attribute(:current_state, 'preauthorize')
    # end
  end

  # Build default payment sum by listing
  # Note: Consider removing this :(
  def default_sum(listing, vat=0)
    self.sum = listing.price
  end
end
