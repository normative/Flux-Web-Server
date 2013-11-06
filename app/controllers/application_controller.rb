class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push :username, :email, :password, :password_confirmation, :name
    devise_parameter_sanitizer.for(:sign_in).push :username, :password
  end
  
  private

  def authenticate_user_from_token!
    auth_token = params[:auth_token].presence
    user = auth_token && User.find_by_authentication_token(auth_token)
    
    if user
      sign_in user, store: false
    end
  end
end
