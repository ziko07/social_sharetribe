class PostsController < ApplicationController

  def create
    status = true
    @post = Post.new(person_id: @current_user.id, post_to_id: params[:post_to_id], listings_ids: params[:listings_ids], description: params[:description], purpose: params[:purpose])
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
      @post.mention_people(params[:user_mention])
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
    mime = MIME::Types.type_for(params[:file].path).first.content_type
    attachment_type = mime.present? ? mime.split('/').first : ''
    attachment = PostAttachment.create(attachment: params[:file], attachment_type: attachment_type)
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

  def destroy
    post = Post.where("id = ? AND (person_id = ? OR post_to_id = ?)", params[:id], @current_user.id, @current_user.id).first
    if post.present?
      status = true
      post.destroy
    else
      status = false
    end
    respond_to do |format|
      format.js { render :layout => false, locals: {status: status, id: post.id} }
    end
  end

  def all_comments
     @post = Post.find_by_id(params[:id])
    comments =  @post.post_comments.all.offset(1)
     respond_to do |format|
       format.js { render :layout => false, locals: {comments: comments} }
     end
  end
end
