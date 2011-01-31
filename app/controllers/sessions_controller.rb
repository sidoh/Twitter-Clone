class SessionsController < ApplicationController
  protect_from_forgery
  include SessionsHelper
  
  before_filter :not_signed_in, :only => :new
  
  def new
    @title = "Sign In"
  end
  
  def create
    user = User.authenticate(
      params[:session][:email],
      params[:session][:password])
      
    if user.nil?
      flash[:error] = "Invalid login."
      @title = 'Sign In'
      render 'new'
    else
      flash[:success] = "You are now logged in."
      sign_in user
      redirect_to_stored_or user
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end

end
