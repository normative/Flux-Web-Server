class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  def create
    build_resource(sign_up_params)

    if resource.save
      render json: resource.as_json(auth_token: resource.authentication_token, email: resource.email), status: 201
      return
    else
      clean_up_passwords resource
      warden.custom_failure!
      render json: resource.errors, status: 422
    end
  end

  def resource_params
    params.require(:user).permit :email, :firstname, :lastname, :password, :password_confirmation, :username, :avatar, :time_zone, :twitch, :twitter, :facebook, :youtube, :remember_me, :slogan, :terms, :dob, :gender, :education, :income
  end
end
