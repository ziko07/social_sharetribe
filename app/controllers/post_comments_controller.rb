class PostCommentsController < ApplicationController

  def create
    post = Post.find_by_id(params[:post_id])
    comment = post.post_comments.create(comment: params[:comment], person_id: @current_user.id)
    if comment.save
      flash[:notice] = 'Comment is successfully Posted'
    else
      flash[:notice] = 'Something Worng Please try latter'
    end
    redirect_to :back
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
