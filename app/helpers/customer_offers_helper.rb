module CustomerOffersHelper

  def get_unread_offer
    @current_user.receiving_offers.where(read: false).count
  end

  def get_listing_from_id(id)
    Listing.find_by_id(id)
  end
end
