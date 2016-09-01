class PostCommentsController < ApplicationController

  def create
    post =  Post.find_by_id(params[:post_id])
    comment =  post.post_comments.create(comment: params[:comment],person_id: @current_user.id)
    if comment.save
      flash[:notice] = 'Comment is successfully Posted'
    else
      flash[:notice] = 'Something Worng Please try latter'
    end
    redirect_to person_path(@current_user)
  end
end
