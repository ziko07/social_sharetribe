class FriendshipsController < ApplicationController


  def add_friend
    person = Person.find_by_username(params[:username])
    @current_user.invite person
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :partial => "people/friend_request_button", :locals => { :person => person } }
    end
  end

  def accept_friend
    person = Person.find_by_username(params[:username])
    @current_user.approve person
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :partial => "people/friend_request_button", :locals => { :person => person } }
    end
  end

  def remove_friend
    person = Person.find_by_username(params[:username])
    @current_user.remove_friendship person
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :partial => "people/friend_request_button", :locals => { :person => person } }
    end
  end


   def friend_list
     person = Person.find_by_username(params[:username])
     @friends = person.friends
     @mutual_friends = person.common_friends_with(@current_user)
     @follower = person.invited_by
     @following = person.invited
   end
end