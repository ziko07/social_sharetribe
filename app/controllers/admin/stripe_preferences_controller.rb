class Admin::StripePreferencesController < ApplicationController
  before_filter :ensure_is_admin

  def index
    @selected_left_navi_link = "stripe_account"
    @payment_settings = PaymentSettings.find_by(community_id: @current_community.id)
    currency = @current_community.default_currency
    payment_settings = {
        payment_settings: @payment_settings,
        currency: currency
    }
    render('index', locals: payment_settings)
  end

  def preferences_update
    @payment_settings = PaymentSettings.find_by(community_id: @current_community.id)

    if @payment_settings.update_attributes(params[:payment_settings])
      flash[:notice] = t("admin.paypal_accounts.preferences_updated")
    else
      flash[:error] = @payment_settings.errors.full_messages.join(", ")
    end
    redirect_to action: :index
  end

  def account_create
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
    response = accounts_api.request(
        body: PaypalService::API::DataTypes.create_create_account_request(
            {
                community_id: @current_community.id,
                callback_url: admin_paypal_preferences_permissions_verified_url,
                country: community_country_code
            }))
    permissions_url = response.data[:redirect_url]

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to action: :index
    else
      render json: {redirect_url: permissions_url}
    end
  end

  def permissions_verified
    unless params[:verification_code].present?
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      return redirect_to action: :index
    end

    response = accounts_api.create(
        community_id: @current_community.id,
        order_permission_request_token: params[:request_token],
        body: PaypalService::API::DataTypes
                  .create_account_permission_verification_request(
                      {
                          order_permission_verification_code: params[:verification_code]
                      }))

    if response[:success]
      redirect_to action: :index
    else
      flash_error_and_redirect_to_settings(error_response: response)
    end
  end

  private

  def parse_preferences(params, currency)
    {
        minimum_listing_price: MoneyUtil.parse_str_to_money(params[:minimum_listing_price], currency),
        minimum_transaction_fee: MoneyUtil.parse_str_to_money(params[:minimum_transaction_fee], currency),
        commission_from_seller: params[:commission_from_seller]
    }
  end

  def flash_error_and_redirect_to_settings(error_response: nil)
    error =
        if (error_response && error_response[:error_code] == "570058")
          t("paypal_accounts.new.account_not_verified")
        elsif (error_response && error_response[:error_code] == "520009")
          t("paypal_accounts.new.account_restricted")
        else
          t("paypal_accounts.new.something_went_wrong")
        end

    flash[:error] = error
    redirect_to action: :index
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions
  end

  def tx_settings_api
    TransactionService::API::Api.settings
  end

  def accounts_api
    PaypalService::API::Api.accounts
  end

end
