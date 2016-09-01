# == Schema Information
#
# Table name: stripe_accounts
#
#  id           :integer          not null, primary key
#  person_id    :string(255)
#  community_id :integer
#  account_id   :string(255)
#  token        :text(65535)
#  public_key   :text(65535)
#  secret_key   :text(65535)
#  state        :string(255)
#  country      :string(255)
#  active       :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class StripeAccount < ActiveRecord::Base
  belongs_to :community
  belongs_to :person
  attr_accessor :account_number, :routing_number, :first_name, :last_name, :dob_day, :dob_month, :dob_year, :address, :city, :state_line, :zip

  ACCOUNT_TYPE = 'individual'
  SUPPORTED_COUNTRY = {
      'Australia' => 'AU',
      'Canada' => 'CA',
      'Denmark' => 'DK',
      'Finland' => 'FI',
      'France' => 'FR',
      'Ireland' => 'IE',
      'Norway' => 'NO',
      'Sweden' => 'SE',
      'United Kingdom' => 'GB',
      'United States' => 'US',
      'Austria' => 'AT',
      'Belgium' => 'BE',
      'Germany' => 'DE',
      'Hong Kong' => 'HK',
      'Italy' => 'IT',
      'Japan' => 'JP',
      'Luxembourg' => 'LU',
      'Netherlands' => 'NL',
      'Portugal' => 'PT',
      'Singapore' => 'SG',
      'Spain' => 'ES',
      'Brazil' => 'BR',
      'Mexico' => 'MX',
      'New Zealand' => 'NZ',
      'Switzerland' => 'CH'
  }

  CURRENCY_MAP = {
      'AU' => 'AUD',
      'CA' => 'CAD',
      'DK' => 'GBP',
      'FI' => 'EUR',
      'FR' => 'USD',
      'IE' => 'USD',
      'NO' => 'NOK',
      'SE' => 'SEK',
      'GB' => 'USD',
      'US' => 'USD',
      'AT' => 'USD',
      'BE' => 'USD',
      'DE' => 'USD',
      'HK' => 'HKD',
      'IT' => 'EUR',
      'JP' => 'JPY',
      'LU' => 'USD',
      'NL' => 'USD',
      'PT' => 'USD',
      'SG' => 'SGD',
      'ES' => 'USD',
      'BR' => 'BRL',
      'MX' => 'MXN',
      'NZ' => 'NZD',
      'CH' => 'CHF'
  }

end