require 'facebook'
require 'twitter_client'
require 'aliases_controller'

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    if params[:user].present? && params[:user][:facebook].present?
      fbuser = OAuth2::Facebook.lookup_by_token params[:user][:facebook]
      self.resource = User.find_from_facebook(fbuser)
      AliasesController.create_or_update_alias self.resource, fbuser["id"], 3  # id or username  
    elsif params[:user].present? && params[:user][:twitter].present?
      twuser = TwitterClient.lookup_by_token params[:user][:twitter]
      self.resource = User.find_from_twitter(twuser)
      AliasesController.create_or_update_alias self.resource, twuser.username, 2  # id matches users.uid, username matches aliases.alias_name  
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
