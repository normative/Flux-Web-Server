class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter {
    request.env['devise.skip_storage'] = true # turn off cookies
  }
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push :username, :email, :password, :name, :bio
    devise_parameter_sanitizer.for(:sign_in).push :username, :password
  end
  
  private

  def authenticate_user_from_token!
    auth_token = params[:auth_token].presence
    # temporary fix until app can be cleaned up properly
    if auth_token[0] == "'"
      auth_token.delete! "'"
    end
    user = auth_token && User.find_by_authentication_token(auth_token)

    if user
      sign_in user, store: false
    end
  end
end
