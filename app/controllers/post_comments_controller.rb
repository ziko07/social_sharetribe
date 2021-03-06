class PostCommentsController < ApplicationController

  def create
    post = Post.find_by_id(params[:post_id])
    comment = post.post_comments.create(comment: params[:comment], person_id: @current_user.id)
    if comment.save
      UserNotification.send_notification(@current_user, post.person,comment,UserNotification::NOTIFICATION_TYPE[:comment])
      flash[:notice] = 'Comment is successfully Posted'
    else
      flash[:notice] = 'Something Worng Please try latter'
    end
    respond_to do |format|
      format.js { render :layout => false,locals: {comment: comment,post: post}}
    end
  end

  def destroy
    comment = @current_user.post_comments.find_by_id(params[:id]);
    if comment.present?
      @id = "comment-#{comment.id}"
      comment.destroy
    end
    respond_to do |format|
      format.js { render :layout => false}
    end
  end
end
