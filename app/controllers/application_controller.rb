# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :authorize, :except => ["index","login","pictures","next_picture","previous_picture","show"]

  def authorize
    session[:current_action] = nil
    session[:current_controller] = nil
    unless action_name == "logout"
			session[:current_action] = action_name 
			session[:current_controller] = controller_name
      User.current_user = User.find(session[:user_id]) unless session[:user_id].nil?
    end
    if session[:user_id].blank?
      redirect_to(:controller => "articles", :action => "index")
    end 
  end
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
