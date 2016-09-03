class PostsController < ApplicationController

  def create
    status = true
    @post = Post.new(person_id: @current_user.id, post_to_id: params[:post_to_id], description: params[:description])
    @post.update_time = Time.now.to_i
    if @post.save
      if params[:attachment_list].present?
        params[:attachment_list].split(',').each do |a|
          post_attachment = PostAttachment.find_by_id(a)
          if post_attachment.present?
            post_attachment.attachmentable_id = @post.id
            post_attachment.attachmentable_type = @post.class
            post_attachment.save
          end
        end
      end
      flash[:notice] = 'Post is successfully Posted'
    else
      status = false
      flash[:notice] = 'Something Worng Please try latter'
    end
    respond_to do |format|
      format.js { render :layout => false, locals: {status: status, post: @post, person: @current_user, message: t("layouts.notifications.message_sent")} }
      format.html {
        redirect_to :back
      }
    end
  end

  def upload_attachment
    attachment = PostAttachment.create(attachment: params[:file])
    respond_to do |format|
      format.json {
        render json: {status: true, attachment_id: attachment.id}
      }
    end
  end

  def remove_attachmnet
    attachment = PostAttachment.find_by_id(params[:attachment_id])
    if attachment.present? && attachment.destroy
      status = true
    else
      status = false
    end
    respond_to do |format|
      format.json {
        render json: {status: status, attachment_id: params[:attachment_id]}
      }
    end
  end
end
