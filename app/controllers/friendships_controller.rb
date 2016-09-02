class FriendshipsController < ApplicationController


  def add_friend
    person = Person.find_by_username(params[:username])
    @current_user.invite person
    respond_to do |format|
      format.js { render layout: false, locals: {person: person} }
      format.html { redirect_to :back }
    end
  end

  def accept_friend
    person = Person.find_by_username(params[:username])
    @current_user.approve person
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render layout: false, locals: {person: person} }
    end
  end

  def remove_friend
    person = Person.find_by_username(params[:username])
    @current_user.remove_friendship person
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render layout: false, locals: {person: person} }
    end
  end
end