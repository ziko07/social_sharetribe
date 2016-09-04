#
# This class makes Braintree calls thread-safe even though we're using
# different configurations per Braintree call
#
module StripeService
  class StripeApi
    class << self

      @@mutex = Mutex.new

      def configure_for(community)
        Braintree::Configuration.environment = community.payment_gateway.braintree_environment.to_sym
        Braintree::Configuration.merchant_id = community.payment_gateway.braintree_merchant_id
        Braintree::Configuration.public_key = community.payment_gateway.braintree_public_key
        Braintree::Configuration.private_key = community.payment_gateway.braintree_private_key
      end

      def reset_configurations
        Braintree::Configuration.merchant_id = nil
        Braintree::Configuration.public_key = nil
        Braintree::Configuration.private_key = nil
      end

      # This method should be used for all actions that require setting correct
      # Merchant details for the Braintree gem
      def with_braintree_config(community, &block)
        @@mutex.synchronize {
          configure_for(community)

          return_value = block.call

          reset_configurations()

          return return_value
        }
      end

      def create_merchant_account(account_params, community, remote_ip)
        begin
          account = Stripe::Account.create(
              {
                  country: account_params[:country],
                  managed: true,
                  external_account: {
                      object: 'bank_account',
                      country: account_params[:country],
                      currency: StripeAccount::CURRENCY_MAP[account_params[:country].upcase],
                      routing_number: account_params[:routing_number],
                      account_number: account_params[:account_number]
                  },
                  legal_entity: {
                      type: StripeAccount::ACCOUNT_TYPE,
                      first_name: account_params[:first_name],
                      last_name: account_params[:last_name],
                      dob: {
                          day: account_params[:dob_day],
                          month: account_params[:dob_month],
                          year: account_params[:dob_year]
                      },
                      address: {
                          line1: account_params[:address],
                          city: account_params[:city],
                          state: account_params[:state_line],
                          postal_code: account_params[:zip],
                      }
                  },
                  tos_acceptance: {
                      date: Time.now.to_i,
                      ip: remote_ip,
                  }
              }
          )
          puts account.inspect
          return {state: true, error: nil, account: account}
        rescue Exception => ex
          return {status: false, error: ex.message}
        end
      end

      def account_verification(account_params, user)
        begin
          account = StripeHelper.get_account(user)
          if account_params[:document].present?
            return upload_document(account, account_params[:document])
          elsif account_params[:ssn_number]
            return update_ssn(account, account_params[:ssn_number])
          elsif account_params[:personal_id]
            return update_personal_number(account, account_params[:personal_id])
          end
        rescue Exception => ex
          return {status: false, message: ex.message}
        end
      end

      def account_verification_status(account_params)
        obj_data = account_params['data']['object']
        if obj_data.present?
          legal_entity = obj_data['legal_entity']['verification']
          user_account = StripeAccount.find_by_account_id(account_params['user_id'])
          if legal_entity.present? && user_account.present?
            user_account.state = legal_entity['status']
            user_account.verification_details = legal_entity['details']
            if user_account.state == 'verified'
              user_account.active = true
            else
              user_account.active = false
            end
            user_account.save
          end
        end
      end

      def upload_document(stripe_account, file)
        status = false
        message = 'Unable to upload document'
        upload = Stripe::FileUpload.create(
            {
                purpose: 'identity_document',
                file: File.new(file.path)
            },
            {stripe_account: stripe_account.id}
        )
        if upload.present?
          stripe_account.legal_entity.verification.document = upload.id
          status = stripe_account.save
        end
        {status: status, message: status ? ' ' : message}
      end

      def update_ssn(stripe_account, ssn)
        message = 'Unable to upload ssn'
        stripe_account.legal_entity.ssn_last_4 = ssn
        status = stripe_account.save
        {status: status, message: status ? '' : message}
      end

      def update_personal_number(stripe_account, personal_id)
        message = 'Unable to upload your personal id number'
        stripe_account.legal_entity.personal_id_number = personal_id
        status = stripe_account.save
        {status: status, message: status ? '' : message}
      end

      def braintree_account_update(id, community, account_details)
        with_braintree_config(community) do
          result = Braintree::MerchantAccount.update(
              id.to_s,
              :individual => {
                  :first_name => account_details[:first_name],
                  :last_name => account_details[:last_name],
                  :email => account_details[:email],
                  :phone => account_details[:phone],
                  :address => {
                      :street_address => account_details[:address_street_address],
                      :locality => account_details[:address_locality],
                      :region => account_details[:address_region],
                      :postal_code => account_details[:address_postal_code],
                  },
              },
              :funding => {
                  :destination => Braintree::MerchantAccount::FundingDestination::Bank,
                  :account_number => account_details[:account_number],
                  :routing_number => account_details[:routing_number],
              },
          )

          if result.success?
            p "Merchant account successfully updated"
            success = "true"
            braintree_account = BraintreeAccount.find_by_person_id(id)
            account_details = account_details.merge(hidden_account_number: StringUtils.trim_and_hide(account_details[:account_number]))
            account_details = account_details.merge(status: result.merchant_account.status)
            braintree_account.update_attributes(account_details)

            return success
          else
            p result.errors
            success = result.errors
            return success
          end
        end


      end

      def transaction_sale(community, options)
        with_braintree_config(community) do
          Braintree::Transaction.create(options)
        end
      end

      def find_transaction(community, transaction_id)
        with_braintree_config(community) do
          Braintree::Transaction.find(transaction_id)
        end
      end

      def submit_to_settlement(tx)
        stripe_payment = StripePayment.find_by_transaction_id(tx[:id])
        recipient = StripeAccount.find_by_person_id(stripe_payment.recipient_id) if stripe_payment.present?
        total_cent = tx[:item_total].to_i * 100
        fee_cent = tx[:commission_total].to_i * 100
        if stripe_payment.present? && recipient.present?
          charge_params = {
              amount: total_cent,
              currency: 'USD',
              application_fee: fee_cent,
              customer: stripe_payment.customer_id,
              destination: recipient.account_id
          }
          begin
            charge = Stripe::Charge.create(charge_params)
            puts "Charge: #{charge.inspect}"
            if charge['status'] == 'succeeded'
              stripe_payment.update_attribute(:status, 'paid')
              return {status: true, charge: charge, message: 'Success'}
            else
              return {status: false, charge: charge, message: charge['status']}
            end
          rescue Exception => ex
            return {status: false, charge: charge, message: ex.message}
          end
        end
      end

      def release_from_escrow(community, transaction_id)
        with_braintree_config(community) do
          Braintree::Transaction.release_from_escrow(transaction_id)
        end
      end

      def void_transaction(customer_id)
        begin
          customer = Stripe::Customer.retrieve(customer_id)
          customer.delete
          return {status: true, message: nil}
        rescue Exception => ex
          return {status: false, message: ex.message}
        end
      end

      def master_merchant_id(community)
        # TODO Move this method, it has nothing to do with the Braintree API
        community.payment_gateway.braintree_master_merchant_id
      end

      def webhook_notification_verify(community, challenge)
        with_braintree_config(community) do
          Braintree::WebhookNotification.verify(challenge)
        end
      end

      def webhook_notification_parse(community, signature, payload)
        with_braintree_config(community) do
          Braintree::WebhookNotification.parse(signature, payload)
        end
      end

      def webhook_testing_sample_notification(community, kind, id)
        with_braintree_config(community) do
          Braintree::WebhookTesting.sample_notification(kind, id)
        end
      end
    end
  end
end