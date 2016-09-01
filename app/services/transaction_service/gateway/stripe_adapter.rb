module TransactionService::Gateway
  class StripeAdapter < GatewayAdapter

    def implements_process(process)
      [:none, :preauthorize].include?(process)
    end

    def create_payment(tx:, gateway_fields:, prefer_async: nil)
      community = Community.find_by_id(tx[:community_id])
      payment = StripePayment.create(
          {
              transaction_id: tx[:id],
              community_id: tx[:community_id],
              status: :pending,
              payer_id: tx[:starter_id],
              recipient_id: tx[:listing_author_id],
              currency: community.default_currency,
              sum_cents: tx[:unit_price] * tx[:listing_quantity]})

      result = StripeService::StripeSaleService.new(payment, gateway_fields).create_customer

      unless result.present?
        SyncCompletion.new(Result::Error.new('Unable to create stripe customer'))
      end
      SyncCompletion.new(Result::Success.new({result: true}))
    end

    def reject_payment(tx:, reason: "")
      result = StripeService::Payments::Command.void_transaction(tx, reason)
      unless result[:status]
        SyncCompletion.new(Result::Error.new(result[:message]))
      end

      SyncCompletion.new(Result::Success.new({result: true}))
    end

    def complete_preauthorization(tx:)
      result = StripeService::Payments::Command.submit_to_settlement(tx, tx[:community_id])

      unless result[:status]
        SyncCompletion.new(Result::Error.new(result[:message]))
      end

      SyncCompletion.new(Result::Success.new({result: true}))
    end

    def get_payment_details(tx:)
      payment = paypal_api.payments.get_payment(tx[:community_id], tx[:id]).maybe

      payment_total = payment[:payment_total].or_else(nil)
      total_price = Maybe(payment[:payment_total].or_else(payment[:authorization_total].or_else(nil)))
                        .or_else(order_total(tx))

      {payment_total: payment_total,
       total_price: total_price,
       charged_commission: payment[:commission_total].or_else(nil),
       payment_gateway_fee: payment[:fee_total].or_else(nil)}
    end


    private

    def stripe_api
      StripeService::API::Api
    end

    def paypal_api
      PaypalService::API::Api
    end

    def order_total(tx)
      # Note: Quantity may be confusing in Paypal Checkout page, thus,
      # we don't use separated unit price and quantity, only the total
      # price for now.

      shipping_total = Maybe(tx[:shipping_price]).or_else(0)
      tx[:unit_price] * tx[:listing_quantity] + shipping_total
    end
  end

end
