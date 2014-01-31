class UsersController < ApplicationController

  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
    @users = params[:ids].present? ? User.where(id: params[:ids].split(',')) : User.order("username ASC")

    respond_to do |format|
      format.html  index.html.erb
      format.json { render json: @users }
    end
  end
  
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
      
    respond_to do |format|
#      format.html  show.html.erb
      format.json { render json: @user }
    end
  end
  
  # GET /users/1/avatar
  def avatar
    @user = User.find(params[:id])
    send_file @user.avatar.path(params[:size]), disposition: :attachment
  end
  
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def profile
    # setup the query but don't execute yet...
    query = ::User.getprofile(params[:auth_token], params[:id])
    # This will issue a query, but only with the attributes we selected above.
    # It also returns a simple Hash, which is significantly more efficient than a
    # full blown ActiveRecord model.
    results = ActiveRecord::Base.connection.select_all(query)
    render json: results
  end
  
  def lookupname
#    by doing it this way, it assumes the user model and always adds an id:null field to each record
#    contacts = User.lookupcontact(params[:auth_token], params[:contact])
#    respond_to do |format|
##      format.html  index.html.erb
#      format.json { render json: contacts }
#    end
#
#   conversely, this way does not add the extra column to the output.        
    query = ::User.lookupcontact(params[:auth_token], params[:contact])
    results = ActiveRecord::Base.connection.select_all(query)
    respond_to do |format|
#      format.html  index.html.erb
      format.json { render json: results }
    end
  end
  
  def user_params
    params.require(:user).permit(:username, :name, :bio, :avatar)
  end
end
