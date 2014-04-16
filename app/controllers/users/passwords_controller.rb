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
  
end
