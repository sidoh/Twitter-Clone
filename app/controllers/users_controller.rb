class UsersController < ApplicationController
  include SessionsHelper 
  
  before_filter :authenticate,  :only => [:index, :edit, :update, :destroy]
  before_filter :correct_user,  :only => [:edit, :update]
  before_filter :not_signed_in, :only => :new
  before_filter :admin_user,    :only => :destroy
  
  def index
    @title = 'All users'
    @users = User.paginate(:page => params[:page])
  end
  
  def new
    @user  = User.new
    @title = 'Sign Up'
  end
  
  def show
    @user  = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      sign_in @user
      flash[:success] = 'Thanks for registering!'
      redirect_to @user
    else
      @title = 'Sign Up'
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
    @title = 'Edit User'
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile successfully updated!"
      redirect_to @user
    else
      @title = 'Edit user'
      render 'edit'
    end
  end
  
  def destroy
    user = User.find(params[:id])
    
    if user == current_user
      flash[:error] = "You cannot delete yourself!"
      redirect_to users_path
    else
      user.destroy
      flash[:success] = "User deleted."
      redirect_to users_path
    end
  end

end
