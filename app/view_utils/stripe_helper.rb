module StripeHelper

  TxApi = TransactionService::API::Api

  module_function

  # Check that we have an active provisioned :paypal payment gateway
  # for the community AND that the community admin has fully
  # configured the gateway.
  def community_ready_for_payments?(community_id)
    account_prepared_for_community?(community_id) &&
        Maybe(TransactionService::API::Api.settings.get_active(community_id: community_id))
            .map { |res| res[:success] ? res[:data] : nil }
            .select { |set| set[:payment_gateway] == :stripe && set[:commission_from_seller] && set[:minimum_price_cents] }
            .map { |_| true }
            .or_else(false)
  end

  # Check that both the community is fully configured with an active
  # :paypal payment gateway and that the given user has connected his
  # paypal account.
  def user_and_community_ready_for_payments?(person_id, community_id)
    StripeHelper.account_prepared_for_user?(person_id, community_id) &&
        StripeHelper.community_ready_for_payments?(community_id)
  end

  # Check that the user has connected his paypal account for the
  # community
  def account_prepared_for_user?(person_id, community_id)
    payment_settings =
        TransactionService::API::Api.settings.get(
            community_id: community_id,
            payment_gateway: :stripe,
            payment_process: :preauthorize)
            .maybe

    account_prepared?(community_id: community_id, person_id: person_id, settings: payment_settings)
  end

  def account_prepared_for_community?(community_id)
    account_prepared?(community_id: community_id)
  end

  def generate_verification_form(current_user, my_account = nil)
    verification = {fields: [], error: nil, status: 'unverified'}
    begin
      account = StripeHelper.get_account(current_user)
      verification[:status] = account.legal_entity['verification']['status']
      puts account.legal_entity.inspect
      if account.present?
        verification[:fields] = account.verification['fields_needed']
        if my_account.present? && account.legal_entity['verification']['status'] == 'verified'
          my_account.update_attributes({state: 'verified', active: true})
        end
      else
        verification[:error] = 'Account Not Found'
      end
    rescue Exception => ex
      verification[:error] = ex.message
    end
    verification
  end

  def get_account(current_user)
    account = StripeAccount.find_by(person_id: current_user.id)
    if account.present?
      Stripe::Account.retrieve(account.account_id)
    end
  end

  # Private
  def account_prepared?(community_id:, person_id: nil, settings: Maybe(nil))
    acc_state = PaymentSettings.find_by(community_id: community_id)
    acc_state.present? && acc_state.active
  end

  private_class_method :account_prepared?

  # Check that the currently active payment gateway (there can be only
  # one active at any time) for the community is :paypal. This doesn't
  # check that the gateway is fully configured. Use
  # community_ready_for_payments? if that's what you need.
  def stripe_active?(community_id)
    active_settings = Maybe(TxApi.settings.get_active(community_id: community_id))
                          .select { |result| result[:success] }
                          .map { |result| result[:data] }
                          .or_else(nil)

    return active_settings && active_settings[:payment_gateway] == :stripe
  end


  # Check if PayPal has been provisioned for a community.
  #
  # This is different from PayPal being active. Provisioned just means
  # that admin can configure and activate PayPal.
  def stripe_provisioned?(community_id)
    settings = Maybe(TxApi.settings.get(
                         community_id: community_id,
                         payment_gateway: :stripe,
                         payment_process: :preauthorize))
                   .select { |result| result[:success] }
                   .map { |result| result[:data] }
                   .or_else(nil)

    return !!settings
  end

  # Check if the user has open listings in the community but has not
  # finished connecting his paypal account.
  def open_listings_with_missing_payment_info?(user_id, community_id)
    paypal_active?(community_id) &&
        !user_and_community_ready_for_payments?(user_id, community_id) &&
        open_listings_with_payment_process?(community_id, user_id)
  end

  def open_listings_with_payment_process?(community_id, user_id)
    processes = TransactionService::API::Api.processes.get(community_id: community_id)[:data]
    payment_process_ids = processes.reject { |p| p[:process] == :none }.map { |p| p[:id] }

    if payment_process_ids.empty?
      false
    else
      listing_count = Listing
                          .where(
                              community_id: community_id,
                              author_id: user_id,
                              open: true,
                              transaction_process_id: payment_process_ids)
                          .count

      listing_count > 0
    end
  end

  def accounts_api
    PaypalService::API::Api.accounts
  end
end
