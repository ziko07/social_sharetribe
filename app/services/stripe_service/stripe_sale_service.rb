#
# Do Braintree payment
#
# This is the same behaviour for both post pay and preauthorize listings
#
module StripeService
  class StripeSaleService
    def initialize(payment, payment_params)
      subunit_to_unit = Money::Currency.new(payment.currency).subunit_to_unit
      @payment = payment
      @params = payment_params || {}
    end

    def create_customer()
      result = call_stripe_api
      if result.present?
        save_transaction_id!(result.id)
        change_payment_status_to_paid!
      end
      result
    end

    private

    def call_stripe_api()
      with_expection_logging do
        Stripe::Customer.create(
            card: @params[:stripe_token],
            description: 'Timelet customer'
        )
      end
    end

    def save_transaction_id!(customer_id)
      @payment.update_attributes(customer_id: customer_id)
    end

    def change_payment_status_to_paid!
      @payment.paid!
    end

    def log_result(result)
      if result.success?
        transaction_id = result.transaction.id
        BTLog.warn("Successful sale transaction #{transaction_id} from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}")
      else
        BTLog.error("Unsuccessful sale transaction from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}: #{result.message}")
      end
    end

    def with_expection_logging(&block)
      begin
        block.call
      rescue Exception => e
        puts e.message
        raise e
      end
    end
  end
end
