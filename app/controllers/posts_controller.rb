class PostsController < ApplicationController

  def create
    @post = Post.new(person_id: @current_user.id, post_to_id: params[:post_to_id], description: params[:description])
    @post.update_time = Time.now.to_i
    if @post.save
      if params[:attachments].present?
        params[:attachments]['attachment'].each do |a|
          @post.post_attachments.create!(:attachment => a)
        end
      end
      flash[:notice] = 'Post is successfully Posted'
    else
      flash[:notice] = 'Something Worng Please try latter'
    end
    respond_to do |format|
      format.html {
        redirect_to :back
      }
    end
  end

  def destroy
    post = Post.where("id = ? AND (person_id = ? OR post_to_id = ?)",params[:id], @current_user.id, @current_user.id).first
    if post.present?
      @id = "post-#{post.id}"
      post.destroy
    end
    respond_to do |format|
      format.js { render :layout => false}
    end
  end
end
