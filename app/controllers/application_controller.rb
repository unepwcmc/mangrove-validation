# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  helper_method :current_user_session, :current_user  
  before_filter :adjust_format_for_apple_requests

  private

  def require_user 
    unless current_user 
      store_location 
      flash[:notice] = "You must be logged in to access this page" 
      redirect_to login_path 
      return false 
    end 
  end
  
  def store_location
    session[:return_to] = request.request_uri unless request.xhr?
  end    
    
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  # detect apple requests  
  def adjust_format_for_apple_requests
    request.format = :iphone if iphone_request?
    request.format = :ipad if ipad_request?
  end
  
  def iphone_request?
    (agent = request.env["HTTP_USER_AGENT"]) && (agent[/(iPhone;.+Mobile\/)/] ||
    params[:agent] == "iphone")
  end

  def ipad_request?
    (agent = request.env["HTTP_USER_AGENT"]) && (agent[/(iPad;.+Mobile\/.+Safari)/] ||
    params[:agent] == "ipad")
  end
end
