class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  def create

    self.resource = nil

    if (resource_params[:email].nil?)
      # lookup based on username
      if (!resource_params[:username].nil?)
        user = User.where(username: resource_params[:username]).first
        if (!user.nil?)
          self.resource = user.send_reset_password_instructions
        else
          err_msg = "user not found"
          status = 422  # unprocessible entity
        end
      else
        err_msg = "Missing username or email property"
        status = 422  # unprocessible entity
      end 
    else
      self.resource = resource_class.send_reset_password_instructions(resource_params)  
    end

    if (self.resource.nil?)
      render status: status, json: {error_msg: err_msg}
    else
      if successfully_sent?(resource)
        render status: 200, json: {}
      else
        render status: 422, json: {}
      end
    end
  end
  
# PUT /resource/password
def update
  self.resource = resource_class.reset_password_by_token(resource_params)

  if resource.errors.empty?
    resource.unlock_access! if unlockable?(resource)
    flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
    set_flash_message(:notice, flash_message) if is_navigational_format?
#    sign_in(resource_name, resource)
#    respond_with resource, :location => after_resetting_password_path_for(resource)
#    respond_with resource, :location => "http://smlr.is"
    respond_with resource, :location => "/users/passwordchanged"
  else
    respond_with resource
  end
end

def changed
    respond_to do |format|
      format.html # changed.html.erb
    end
end

# could override this as well but since we already need to override the update to eliminate the sign_in, we can make the change there.
#protected
#  def after_resetting_password_path_for(resource)
#    after_sign_in_path_for(resource)
#  end

end
