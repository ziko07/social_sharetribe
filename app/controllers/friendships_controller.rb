class FriendshipsController < ApplicationController


  def add_friend
    person = Person.find_by_username(params[:username])
    @current_user.invite person
    if person.privacy.auto_follower?
      person.approve @current_user
    end
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

  def block_friend
    person = Person.find_by_username(params[:username])
    if @current_user.blocked?(person)
      @current_user.unblock(person)
      @text = "Block"
    else
      @current_user.block(person)
      @text = "Unblock"
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render layout: false, locals: {person: person} }
    end
  end
end