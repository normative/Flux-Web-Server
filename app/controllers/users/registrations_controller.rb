class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  def create
    build_resource(sign_up_params)

    if resource.save
      render json: resource.as_json(auth_token: resource.authentication_token, username: resource.username), status: 201
      return
    else
      clean_up_passwords resource
      warden.custom_failure!
      render json: resource.errors, status: 422
    end
  end

  # GET /users/registrations/suggestuniqueuname.json?username=...
  def suggestuniqueuname
#    @count = User.where(username: params[:username]).select("id").count
    @result = User.usernameisunique(params[:username])
    render json: @result
    return
  end
  
  def resource_params
    params.require(:user).permit :email, :username, :name, :password, :bio
  end
end
