class StripeAccountsController < ApplicationController
  before_filter except: [:webhooks] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter :ensure_stripe_enabled, except: [:webhooks]
  skip_before_action :verify_authenticity_token, only: [:webhooks]
  layout 'setting'

  def index
    @m_account = accounts_api(@current_user.id)

    @selected_left_navi_link = "payments"

    community_ready_for_payments = StripeHelper.community_ready_for_payments?(@current_community)
    unless community_ready_for_payments
      flash.now[:warning] = t("paypal_accounts.admin_account_not_connected",
                              contact_admin_link: view_context.link_to(
                                  t("paypal_accounts.contact_admin_link_text"),
                                  new_user_feedback_path)).html_safe
    end

    community_currency = @current_community.default_currency
    payment_settings = payment_settings_api.get_active(community_id: @current_community.id).maybe.get
    stripe_account = StripeHelper.get_account(@current_user)
    verification_form = stripe_account.present? ? StripeHelper.generate_verification_form(stripe_account) : []
    render(locals: {
               next_action: next_action(@m_account.state),
               community_ready_for_payments: community_ready_for_payments,
               left_hand_navigation_links: settings_links_for(@current_user, @current_community),
               order_permission_action: ask_order_permission_person_paypal_account_path(@current_user),
               billing_agreement_action: ask_billing_agreement_person_paypal_account_path(@current_user),
               commission_from_seller: t("paypal_accounts.commission", commission: payment_settings[:commission_from_seller]),
               minimum_commission: Money.new(payment_settings[:minimum_transaction_fee_cents], community_currency),
               commission_type: payment_settings[:commission_type],
               currency: community_currency,
               my_account: @m_account,
               verification_form: verification_form,
               stripe_account: stripe_account
           })
  end

  def create_account
    @m_account = @current_user.build_stripe_account(stripe_params)
    @selected_left_navi_link = 'payments'
    community_currency = @current_community.default_currency
    payment_settings = payment_settings_api.get_active(community_id: @current_community.id).maybe.get
    stripe_account = StripeHelper.get_account(@current_user)
    verification_form = stripe_account.present? ? StripeHelper.generate_verification_form(stripe_account) : []
    res = StripeService::StripeApi.create_merchant_account(stripe_params, @current_community, request.remote_ip)
    if res[:error]
      flash[:error] = res[:error]
      view_params = {
          next_action: next_action(@m_account.state),
          community_ready_for_payments: true,
          left_hand_navigation_links: settings_links_for(@current_user, @current_community),
          order_permission_action: ask_order_permission_person_paypal_account_path(@current_user),
          billing_agreement_action: ask_billing_agreement_person_paypal_account_path(@current_user),
          commission_from_seller: t('paypal_accounts.commission', commission: payment_settings[:commission_from_seller]),
          minimum_commission: Money.new(payment_settings[:minimum_transaction_fee_cents], community_currency),
          commission_type: payment_settings[:commission_type],
          currency: community_currency,
          my_account: @m_account,
          verification_form: verification_form
      }
      render action: :index, locals: view_params
    else
      account = res[:account]
      @m_account.community_id = @current_community.id
      @m_account.account_id = account['id']
      @m_account.public_key = account['keys']['publishable']
      @m_account.secret_key = account['keys']['secret']
      @m_account.state = 'connected'
      @m_account.save!
      redirect_to action: :index
    end
  end

  def verify_account
    return redirect_to action: :index unless StripeHelper.community_ready_for_payments?(@current_community)
    res = StripeService::StripeApi.account_verification(params, current_user)
    if res[:status]
      flash[:notice] = 'Verification in progress'
    else
      flash[:error] = res[:message]
    end
    stripe_account = StripeHelper.get_account(@current_user)
    StripeHelper.generate_verification_form(stripe_account, current_user.stripe_account)
    redirect_to action: :index
  end

  def permissions_verified

    unless params[:verification_code].present?
      return flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.permissions_not_granted"))
    end

    response = accounts_api.create(
        community_id: @current_community.id,
        person_id: @current_user.id,
        order_permission_request_token: params[:request_token],
        body: PaypalService::API::DataTypes.create_account_permission_verification_request(
            {
                order_permission_verification_code: params[:verification_code]
            }
        ),
        flow: :old)

    if response[:success]
      redirect_to paypal_account_settings_payment_path(@current_user.username)
    else
      flash_error_and_redirect_to_settings(error_response: response) unless response[:success]
    end
  end

  def billing_agreement_success
    response = accounts_api.billing_agreement_create(
        community_id: @current_community.id,
        person_id: @current_user.id,
        billing_agreement_request_token: params[:token]
    )

    if response[:success]
      redirect_to paypal_account_settings_payment_path(@current_user.username)
    else
      case response.error_msg
        when :billing_agreement_not_accepted
          flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.billing_agreement_not_accepted"))
        when :wrong_account
          flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.billing_agreement_wrong_account"))
        else
          flash_error_and_redirect_to_settings(error_response: response)
      end
    end
  end

  def billing_agreement_cancel
    accounts_api.delete_billing_agreement(
        community_id: @current_community.id,
        person_id: @current_user.id
    )

    flash[:error] = t("paypal_accounts.new.billing_agreement_canceled")
    redirect_to paypal_account_settings_payment_path(@current_user.username)
  end

  def webhooks
    StripeService::StripeApi.account_verification_status(params)
    render nothing: true
  end


  private

  def next_action(stripe_account_state)
    if stripe_account_state == 'verified'
      :none
    elsif stripe_account_state == 'connected'
      :verify_account
    else
      :create_account
    end
  end

  def stripe_params
    params.require(:stripe_account).permit!
  end

  # Before filter
  def ensure_stripe_enabled
    unless StripeHelper.stripe_active?(@current_community.id)
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to person_settings_path(@current_user)
    end
  end

  def flash_error_and_redirect_to_settings(error_response: nil, error_msg: nil)
    error_msg =
        if (error_msg)
          error_msg
        elsif (error_response && error_response[:error_code] == "570058")
          t("paypal_accounts.new.account_not_verified")
        elsif (error_response && error_response[:error_code] == "520009")
          t("paypal_accounts.new.account_restricted")
        else
          t("paypal_accounts.new.something_went_wrong")
        end

    flash[:error] = error_msg
    redirect_to action: error_redirect_action
  end

  def error_redirect_action
    :index
  end

  def payment_gateway_commission(community_id)
    p_set =
        Maybe(payment_settings_api.get_active(community_id: community_id))
            .map { |res| res[:success] ? res[:data] : nil }
            .select { |set| set[:payment_gateway] == :paypal }
            .or_else(nil)

    raise ArgumentError.new("No active paypal gateway for community: #{community_id}.") if p_set.nil?

    p_set[:commission_from_seller]
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions
  end

  def payment_settings_api
    TransactionService::API::Api.settings
  end

  def accounts_api(person_id)
    StripeAccount.find_by(person_id: person_id) || StripeAccount.new
  end

end
