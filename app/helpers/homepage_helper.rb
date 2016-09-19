module HomepageHelper
  def show_subcategory_list(category, current_category_id)
    category.id == current_category_id || category.children.any? do |child_category|
      child_category.id == current_category_id
    end
  end

  def with_first_listing_image(listing, &block)
    Maybe(listing)
        .listing_images
        .map { |images| images.first }[:small_3x2].each { |url|
      block.call(url)
    }
  end

  def linting_grid_view_image(listing)
    listing.listing_images.present? ? listing.listing_images.first.small_3x2 : '/assets/image_not_found.jpg'
  end

  def get_listing_view_image(listing)
    listing.listing_images.present? ? listing.listing_images.first.image.url(:small_3x2) : '/assets/image_not_found.jpg'
  end

  def without_listing_image(listing, &block)
    if listing.listing_images.size == 0
      block.call
    end
  end

  def format_distance(distance)
    precision = (distance < 1) ? 1 : 2
    (distance < 0.1) ? "< #{number_with_delimiter(0.1, locale: locale)}" : number_with_precision(distance, precision: precision, significant: true, locale: locale)
  end
end