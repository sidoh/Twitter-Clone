module SessionsHelper
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    current_user = user
  end
  
  def sign_out
    cookies.delete(:remember_token)
    current_user = nil
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  
  def redirect_to_stored_or(action)
    redirect_to(session[:return_to] || action)
    clear_stored_location
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def not_signed_in
    if signed_in?
      @title = current_user.name
      flash[:info] = 'You are already logged in!  Please logout first.'
      redirect_to user_path(current_user)
    end
  end
  
private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
    
    def store_location
      session[:return_to] = request.fullpath
    end
    
    def clear_stored_location
      session[:return_to] = nil
    end
end
