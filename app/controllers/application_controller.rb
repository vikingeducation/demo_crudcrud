class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login

  private
  def sign_in(user)
    user.regenerate_auth_token
    cookies[:auth_token] = user.auth_token
    @current_user = user
  end
  def permanent_sign_in(user)
    user.regenerate_auth_token
    cookies.permanent[:auth_token] = user.auth_token
    @current_user = user
  end

  def sign_out
    @current_user = nil
    cookies.delete(:auth_token)
  end

  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end
  helper_method :current_user

  def signed_in_user?
    !!current_user
  end
  helper_method :signed_in_user?

  def require_current_user
    unless params[:id] == current_user.id.to_s
      flash[:error] = "You're not authorized to view this"
      redirect_to root_url
    end
  end 

  def require_login
    unless signed_in_user?
      flash[:error] = "Not Authorized, please sign in"
      redirect_to login_path
    end
  end

  # Note: obsolete since we're using sessions now
  def authenticate_user
    # This filter will allow the user to pass if it returns true
    # and the method here passes in the username and password
    # the user provided in the login form
    authenticate_or_request_with_http_basic('Message to User') do |username, password|
      username == 'foo' && password == 'bar'
    end
  end
end
