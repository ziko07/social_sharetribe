module StripeService
  module Payments
    CommunityModel = ::Community

    module Entity
      #in db these can be null.
      BraintreeSettings = EntityUtils.define_builder(
          [:environment, :mandatory, :symbol],
          [:merchant_id, :mandatory, :string],
          [:public_key, :mandatory, :string],
          [:private_key, :mandatory, :string]
      )

      module_function

      def braintree_settings(payment_gateway)

        BraintreeSettings[
            environment: payment_gateway.braintree_environment.to_sym,
            merchant_id: payment_gateway.braintree_merchant_id,
            public_key: payment_gateway.braintree_public_key,
            private_key: payment_gateway.braintree_private_key,
            braintree_client_side_encryption_key: payment_gateway.braintree_client_side_encryption_key
        ]
      end
    end

    module Command
      module_function

      def submit_to_settlement(tx, community_id)
        StripeService::StripeApi.submit_to_settlement(tx)
      end

      def void_transaction(tx, note)
        stripe_payment = StripePayment.find_by_transaction_id(tx[:id])
        res = StripeApi.void_transaction(stripe_payment.customer_id)
        if res[:status]
          stripe_payment.update_attribute({status: 'rejected', customer_id: ''})
        end
        res
      end
    end

    module Query

      module_function

      def braintree_settings(community_id)
        Maybe(CommunityModel.find_by_id(community_id))
            .map { |community|
          if community.payment_gateway.present? && community.payment_gateway.gateway_type == :braintree
            BraintreeService::Payments::Entity.braintree_settings(community.payment_gateway)
          else
            nil
          end
        }.or_else(nil)
      end
    end
  end
end
