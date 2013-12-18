class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    resource.save!
    render json: {
      auth_token: resource.authentication_token, id: resource.id
    }
  end
  
  def destroy
    sign_out(resource_name)
  end
end
