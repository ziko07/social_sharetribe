class PostsController < ApplicationController

  def create
   post = Post.new(person_id: @current_user.id, post_to_id: params[:post_to_id] ,description: params[:description])
   if post.save
     params[:attachments]['attachment'].each do |a|
      post.post_attachments.create!(:attachment => a)
     end
     flash[:notice] = 'Post is successfully Posted'
   else
     flash[:notice] = 'Something Worng Please try latter'
   end
   redirect_to person_path(@current_user)
  end
end
