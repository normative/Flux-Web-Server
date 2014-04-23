require 'facebook'
require 'twitter_client'

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    if params[:user].present? && params[:user][:facebook].present?
      fbuser = OAuth2::Facebook.lookup_by_token params[:user][:facebook]
      self.resource = User.find_from_facebook(fbuser)
      Alias.create_or_update_alias self.resource, fbuser.identifier, 3    
    elsif params[:user].present? && params[:user][:twitter].present?
      twuser = TwitterClient.lookup_by_token params[:user][:twitter]
      self.resource = User.find_from_twitter(twuser)
      Alias.create_or_update_alias self.resource, twuser.username, 2    
    else      
      self.resource = warden.authenticate!(auth_options)
    end
    sign_in resource_name, resource, store: false
    resource.last_sign_in_at = Time.now
    resource.sign_in_count += 1
    resource.save!
    render json: {
      auth_token: resource.authentication_token, id: resource.id, email: resource.email, username: resource.username
    }
  end

  def destroy
    User.where(authentication_token: params[:auth_token]).update_all(authentication_token: nil)
    reset_session
    head :no_content
  end
end
