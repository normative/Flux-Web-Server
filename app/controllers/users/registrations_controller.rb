class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(resource_params)

    if resource.save
      result = resource.as_json(auth_token: resource.authentication_token, username: resource.username)
      result.merge!('auth_token' => resource.authentication_token)
      result.merge!('username' => resource.username)
      render json: result, status: 201
      return
    else
      clean_up_passwords resource
      warden.custom_failure!
      render json: resource.errors, status: 422
      return
    end
  end

  # GET /users/suggestuniqueuname.json?username=...
  def suggestuniqueuname
#    @count = User.where(username: params[:username]).select("id").count
    @result = User.usernameisunique(params[:username])
    render json: @result
    return
  end

#  # GET /users/profile/1.json
#  def profile
#    #    @profile = User.getprofile(params[:auth_token], params[:id])
#
#    # setup the query but don't execute yet...
#    query = User.getprofile(params[:auth_token], params[:id])
#    # This will issue a query, but only with the attributes we selected above.
#    # It also returns a simple Hash, which is significantly more efficient than a
#    # full blown ActiveRecord model.
#    results = ActiveRecord::Base.connection.select_all(query)
#    #=> [{"id" => 1, "member_since" => 2013-02-26 01:28:08 UTC}, etc...]
#    render json: results
#    return
#  end
#
  def resource_params
    params.require(:user).permit :email, :username, :name, :password, :bio, :follower_count, :following_count, :avatar, :facebook, twitter: [:access_token, :access_token_secret]
  end
end
