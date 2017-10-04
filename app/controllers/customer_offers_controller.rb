class CustomerOffersController < ApplicationController

  def offer_list

  end


  def new
    @listing =  Listing.find_by_id(params[:listing_id])
    @customer_offer =  @listing.customer_offers.new
  end

  def create
    @listing =  Listing.find_by_id(params[:listing_id])
    @customer_offer =  @listing.customer_offers.find_or_initialize_by(payer_id: @current_user.id)
    @customer_offer.mobile = params[:customer_offer][:mobile]
    @customer_offer.amount = params[:customer_offer][:amount]
    @customer_offer.content = params[:customer_offer][:content]
    @customer_offer.community_id = @current_community.id
    @customer_offer.currency = @current_community.default_currency
    @customer_offer.recipient_id = @listing.author_id
    if @customer_offer.save
      flash[:notice] = "Your offer is successfully send to the owner"
      redirect_to listing_path(@listing)
    else
      flash[:error] = "Something Worng try again"
      new_listing_customer_offer_path(listing_id: @listing.id)
    end
  end
end
