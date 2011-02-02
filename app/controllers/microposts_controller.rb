class MicropostsController < ApplicationController
  include SessionsHelper
  
  before_filter :authenticate, :only => [:create, :destroy]
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end
  
  def destroy
    micropost = Micropost.find_by_id(params[:id])
    
    if micropost.user == current_user or current_user.admin?
      flash[:success] = "Micropost deleted"
      micropost.destroy
      redirect_to root_path
    else
      redirect_to root_path
    end
  end
end
