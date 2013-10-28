class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      render status: 200, json: {}
    else
      render status: 422, json: {}
    end
  end
end
