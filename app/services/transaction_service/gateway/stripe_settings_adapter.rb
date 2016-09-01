module TransactionService::Gateway
  class StripeSettingsAdapter < SettingsAdapter

    PaymentSettingsStore = TransactionService::Store::PaymentSettings

    def configured?(community_id:, author_id:)
      payment_settings = Maybe(PaymentSettingsStore.get_active(community_id: community_id))
                             .select { |set| stripe_settings_configured?(set) }

      personal_account_verified = stripe_account_verified?(community_id: community_id, person_id: author_id, settings: payment_settings)
      community_account_verified = true #stripe_account_verified?(community_id: community_id)
      payment_settings_available = payment_settings.map { |_| true }.or_else(false)
      puts [personal_account_verified, community_account_verified, payment_settings_available]
      [personal_account_verified, community_account_verified, payment_settings_available].all?
    end

    def tx_process_settings(opts_tx)
      currency = opts_tx[:unit_price].currency
      p_set = PaymentSettingsStore.get_active(community_id: opts_tx[:community_id])

      {minimum_commission: Money.new(p_set[:minimum_transaction_fee_cents], currency),
       commission_from_seller: p_set[:commission_from_seller],
       automatic_confirmation_after_days: p_set[:confirmation_after_days]}
    end

    private

    def stripe_settings_configured?(settings)
      settings[:payment_gateway] == :stripe && !!settings[:commission_from_seller] && !!settings[:minimum_price_cents]
    end

    def stripe_account_verified?(community_id:, person_id: nil, settings: Maybe(nil))
      acc_state = StripeAccount.where(community_id: community_id, person_id: person_id).first
      #     PaypalService::API::Api.accounts.get(community_id: community_id, person_id: person_id)
      #             .maybe()
      #             .fetch(:state, nil)
      #             .or_else(:not_connected)
      # commission_type = settings[:commission_type].or_else(nil)

      acc_state.present? && acc_state.state.to_sym == :verified
      #acc_state == :verified || (acc_state == :connected && commission_type == :none)
    end

  end
end
