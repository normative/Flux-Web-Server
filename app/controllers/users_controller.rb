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
      
#    if (!@user.avatar.nil?)
    path = @user.avatar.path(params[:size])
    if (!path.nil?)
#      send_file @user.avatar.url(params[:size]), disposition: :attachment
#      send_file @user.avatar.expiring_url(300, params[:size]), disposition: :attachment
      if (Rails.env == 'production') || (Rails.env == 'staging')
        data = open(@user.avatar.expiring_url(5,params[:size]))
        send_data data.read, filename: @user.avatar_file_name, type: @user.avatar_content_type
      else
        send_file path, disposition: :attachment
      end
      
    else
      respond_to do |format|
        # should be no_content but earlier versions of the app will fail if a 200-level response is given with no image
        # force a 500 for now until the apps have been updated
        format.json { head :no_content }
#        format.json { head :internal_server_error }
      end
    end
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

  # PATCH/PUT /users/updateapnstoken
  # PATCH/PUT /users/updateapnstoken.json
  def updateapnstoken
    @user = User.find_by_authentication_token(params[:auth_token])
    uph = {apns_device_token: params[:apns_token]}
    respond_to do |format|
      if @user.update_attributes(uph)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
    
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # PUT /users/invitetoflux?service_id=[1|2|3]&auth_token=...[&to_email=...]
  # PUT /users/invitetoflux.json?service_id=[1|2|3]&auth_token=...[&to_email=...]
  def invitetoflux
#    logger.debug "Into Users#invitetoflux"
    # Invite a social contact to join Flux
    
    service_id = params[:serviceid].to_i
 #   puts 'service_id = ' + service_id.to_s
      
    # default result state
    result = :unprocessable_entity
    e_message = "Invalid service id"
      
    if (service_id == 1)
      # email invite
      user = User.find_by_authentication_token(params[:auth_token])
      email_to = params[:email_to]
      if (user.confirmed_at.nil?)
        e_message = "Sender email not confirmed"
      elsif (user.nil?)
        e_message = "Sending user not found" 
      elsif (email_to.nil?)
        e_message = "Missing parameter: email_to" 
      else 
        UserMailer.invite_email(user, email_to)
        result = :ok
      end
    elsif (service_id == 2)
      # twitter invite
#      invite = ::TwitterClient.invite_friend_to_flux params
#      if (!invite.nil?)
#        result = :ok
#      end
    elsif (service_id == 3)
      # facebook invite
    end
    
    respond_to do |format|
#      format.html { redirect_to users_url }
      if (result == :ok)
        format.json { head result }
      else
        format.json { render json: {error_message: e_message}, status: result }           
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
  
  def validateemail
    @user = User.find(params[:id])
      
    if @user.email_validation_token == params[:email_token]
      uph = {email_validation_token: '', email_state: 2}
      respond_to do |format|
        if @user.update_attributes(uph)
          format.html { redirect_to @user, notice: 'Email successfully Validated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to @user, notice: 'Email not Validated.' }
          format.json { head :no_content }
        end
      end
    else
      format.html { redirect_to @user, notice: 'Invalid email validation.' }
      format.json { head :no_content }
    end
  end
  
  
  def user_params
    params.require(:user).permit(:username, :name, :bio, :avatar, :apns_device_token)
  end
end
