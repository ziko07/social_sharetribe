class LikesController < ApplicationController

  def create
   if params[:likeable_type] == 'post'
     @post = Post.find_by_id(params[:likeable_id])
     @like =  @post.likes.create(person_id: @current_user.id)
     UserNotification.send_notification(@current_user, @post.person,@post,UserNotification::NOTIFICATION_TYPE[:post_like])
   elsif params[:likeable_type] == 'comment'
     @comment = PostComment.find_by_id(params[:likeable_id])
     @like =  @comment.likes.create(person_id: @current_user.id)
     UserNotification.send_notification(@current_user, @comment.person,@comment,UserNotification::NOTIFICATION_TYPE[:comment_like])
   end

   respond_to do |format|
     format.js { render :layout => false}
   end
  end

  def destroy
    like = Like.find_by_id(params[:id])
    @likeable_id = like.likeable_id
    @likeable_type = like.likeable_type.downcase
    like.destroy
    if @likeable_type == 'post'
      @post = Post.find_by_id(@likeable_id)
    else
      @comment =  PostComment.find_by_id(@likeable_id)
      @likeable_type = 'comment'
    end
    respond_to do |format|
      format.js { render :layout => false}
    end
  end
end
