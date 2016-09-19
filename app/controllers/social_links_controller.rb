class SocialLinksController < ApplicationController

   layout 'setting'
  def index
    @social_links = social_link_account(@current_user.id)
    @selected_left_navi_link = "social_links"
  end

  def create
    social_link =  @current_user.build_social_link(stripe_params)
    if social_link.save
      flash[:notice] = 'Social Link has been successfully saved'
    else
      flash[:notice] = 'Something Worng Please try latter'
    end
    redirect_to social_link_settings_path(@current_user)
  end

  def update
    social_link = social_link_account(@current_user)
    if social_link.update(stripe_params)
      flash[:notice] = 'Social Link has been successfully saved'
    else
      flash[:notice] = 'Something Worng Please try latter'
    end
    redirect_to social_link_settings_path(@current_user)
  end

  private
  def social_link_account(person_id)
    SocialLink.find_by(person_id: person_id) || SocialLink.new
  end

  def stripe_params
    params.require(:social_link).permit!
  end

end
