require 'apns_client'

class ConnectionsController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  authorize_resource

  # GET /connections
  # GET /connections.json
  def index
    @connections = params[:ids].present? ? Connection.where(id: params[:ids].split(','))  : Connection.order("user_id DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @connections }
    end
  end

  # GET /connections/1
  # GET /connections/1.json
  def show
    @connection = Connection.find(params[:id])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connection }
    end
  end

#  # GET /connections/friends
#  # GET /connections/friends.json
#  def friends
#    @connections = Connection.getfriends(params[:auth_token])
#
#    respond_to do |format|
##      format.html # show.html.erb
#      format.json { render json: @connections }
#    end
#  end

  # GET /connections/following
  # GET /connections/following.json
  def following
    @connections = Connection.getfollowing(params[:auth_token], 0)

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connections }
    end
  end

  # GET /connections/followers
  # GET /connections/followers.json
  def followers
    @connections = Connection.getfollowing(params[:auth_token], 1)

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connections }
    end
  end

  # GET /connections/followerrequests
  # GET /connections/followerrequests.json
  def followerrequests
    @connections = Connection.getfollowerrequests(params[:auth_token])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connections }
    end
  end

  # POST /connections?auth_token=...
  # POST /connections.json?auth_token=...
  def create
#    ct = connection_params[:connection_type].to_i
#    if (!ct.nil?)
#      if (ct == 1)     # follow
        self.localfollow connection_params
#      elsif (ct == 2)  #friend
#        self.localaddfriend connection_params
#      else
#        respond_to do |format|
#          format.json { render json: {error_message: "invalid connection type"}, status: :unprocessable_entity }
#        end
#      end
#    else
#      respond_to do |format|
#        format.json { render json: {error_mesage: "missing connection type"}, status: :unprocessable_entity }
#      end
#    end
  end


  # POST /connections/follow
  # POST /connections/follow.json
  def follow
    connparam = connection_params

    sendMessage = false

    cp = connparam

    fs = cp[:following_state]
    if (fs.nil?)
      cp[:following_state] = 1
    elsif
      cp.merge!( following_state: 1)
    end

    # first, search for an existing connection from "me" to "them"
    @connection = Connection.where("user_id = :userid AND connections_id = :connid",
                                      userid: connparam[:user_id],
                                      connid: connparam[:connections_id]).first

    if (@connection.nil?)
      # new request - create the record and send the request message
      @connection = Connection.new(cp)
      sendMessage = true
#      ApnsClient.sendmessage(@connection.user_id, @connection.connections_id, 1)
    end

    respond_to do |format|
      if @connection.save
        if sendMessage
          # ApnsClient.sendmessage(@connection.user_id, @connection.connections_id, 1)
        end

 #       format.html { redirect_to @connection, notice: 'Connection was successfully created.' }
        format.json { render json: @connection, status: :created, location: @connection }
      else
 #       format.html { render action: "new" }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end

  end

#  def localfollow connparam
##    logger.debug "Into Connection#follow"
#
#    if connparam.nil?
#      connparam = connection_params  # grab a copy of the hash from the function
#    end
#
#    cp = connparam.except(:connection_type)
#
#    af = cp[:am_following]
#    if (af.nil?)
#      cp[:am_following] = 1
#    elsif
#      cp.merge!( am_following: 1)
#    end
#
#    fs = cp[:friend_state]
#    if (fs.nil?)
#      cp[:friend_state] = 0
#    elsif
#      cp.merge!( friend_state: 0)
#    end
#
#    @connection = Connection.where("user_id = :userid AND connections_id = :connid",
#                                    userid: connparam[:user_id],
#                                    connid: connparam[:connections_id]).first_or_create(cp)
#
#    # may need to update if the record already exists
#    if (!@connection.nil?)
#      if (@connection.am_following != 1)
#        cp.merge!( friend_state: @connection.friend_state)
#        @connection.update_attributes(cp)
#      end
#    end
#
#    # notify the user being followed...
#    ApnsClient.sendmessage(@connection.user_id, @connection.connections_id, 3)
#
#    respond_to do |format|
#      if @connection.save
# #       format.html { redirect_to @connection, notice: 'Connection was successfully created.' }
#        format.json { render json: @connection, status: :created, location: @connection }
#      else
# #       format.html { render action: "new" }
#        format.json { render json: @connection.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # POST /connections/addfollower
#  # POST /connections/addfollower.json
#  def addfollow
#    self.localaddfollower connection_params
#  end
#
#  def localfollow connparam
##    logger.debug "Into Connection#follow"
#
#    if connparam.nil?
#      connparam = connection_params  # grab a copy of the hash from the function
#    end
#
#    cp = connparam.except(:connection_type)
#
#    fs = cp[:following_state]
#    if (fs.nil?)
#      cp[:following_state] = 1
#    elsif
#      cp.merge!( following_state: 1)
#    end
#
#    # first, create the connection from "me" to "them"
#    @connection = Connection.where("user_id = :userid AND connections_id = :connid",
#                                      userid: connparam[:user_id],
#                                      connid: connparam[:connections_id]).first
#
#    if (@connection.nil?)
#      @connection = Connection.new(cp)
#      ApnsClient.sendmessage(@connection.user_id, @connection.connections_id, 1)
#    end
#
#    respond_to do |format|
#      if @connection.save
# #       format.html { redirect_to @connection, notice: 'Connection was successfully created.' }
#        format.json { render json: @connection, status: :created, location: @connection }
#      else
# #       format.html { render action: "new" }
#        format.json { render json: @connection.errors, status: :unprocessable_entity }
#      end
#    end
#  end

  # PUT /connections/respondtofollower?
  # PUT /connections/respondtofollower.json
  def respondtofollowrequest
#    @connection = Connection.find(params[:id])

    conparam = Hash.new

    # find the requesting connection (reciprocal to POST payload)
    @connection = Connection.where("user_id = :connid AND connections_id = :userid",
                                      userid: connection_params[:user_id],
                                      connid: connection_params[:connections_id]).first

    if (!connection_params[:following_state].nil?)
      if (connection_params[:following_state].to_i > 0)
#        conparam[:user_id] = connection_params[:user_id]
#        conparam[:connections_id] = connection_params[:connections_id]

        respond_to do |format|
          conparam[:following_state] = 2
          if @connection.update_attributes(conparam)
            logger.debug("Send follower accepted to other user")
            # ApnsClient.sendmessage(@connection.connections_id, @connection.user_id, 2)
#           format.html { redirect_to @connection, notice: 'Connection was successfully updated.' }
            format.json { head :no_content }
          else
#           format.html { render action: "edit" }
            format.json { render json: @connection.errors, status: :unprocessable_entity }
          end
        end

      else
        @connection.destroy

        respond_to do |format|
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.json { render json: {error_message: "missing following_state"}, status: :unprocessable_entity }
      end

    end
  end


  # PATCH/PUT /connections/1
  # PATCH/PUT /connections/1.json
  def update
    @connection = Connection.find(params[:id])

    respond_to do |format|
      if @connection.update_attributes(connection_params)
 #       format.html { redirect_to @connection, notice: 'Connection was successfully updated.' }
        format.json { head :no_content }
      else
 #       format.html { render action: "edit" }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /connections/disconnect
  # PATCH/PUT /connections/disconnect.json
  def disconnect
#    @connection = Connection.find(params[:id])

    @connection = Connection.where("user_id = :userid AND connections_id = :connid",
                                      userid: connection_params[:user_id],
                                      connid: connection_params[:connections_id]).first

    if (@connection.nil?)
      respond_to do |format|
#       format.html { redirect_to @connection, notice: 'Connection was successfully updated.' }
        format.json { head :no_content }
      end
      return
    end

    respond_to do |format|
      if @connection.destroy
 #       format.html { redirect_to @connection, notice: 'Connection was successfully updated.' }
        format.json { head :no_content }
      else
 #       format.html { render action: "edit" }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /connections/1
  # DELETE /connections/1.json
  def destroy
    @connection = Connection.find(params[:id])
    @connection.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end


  private

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def connection_params
    params.require(:connection).permit(:user_id, :connections_id, :following_state)
  end
end
