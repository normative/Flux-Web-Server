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

  # GET /connections/friends
  # GET /connections/friends.json
  def friends
    @connections = Connection.getfriends(params[:auth_token])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connections }
    end
  end

  # GET /connections/followers
  # GET /connections/followers.json
  def followers
    @connections = Connection.getfollowers(params[:auth_token])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connections }
    end
  end
  
  # GET /connections/friendinvites
  # GET /connections/friendinvites.json
  def friendinvites
    @connections = Connection.getfriendinvites(params[:auth_token])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connections }
    end
  end
  
  # POST /connections/follow
  # POST /connections/follow.json
  def follow
#    logger.debug "Into Connection#follow"

    cp = connection_params  # use a copy since original treated as const and can't change

    af = cp[:am_following]
    if (af.nil?)
      cp[:am_following] = 1
    elsif
      cp.merge!( am_following: 1)
    end
    
    fs = cp[:friend_state]
    if (cs.nil?)
      cp[:friend_state] = 0
    elsif
      cp.merge!( friend_state: 0)
    end

    @connection = Connection.where("user_id = :userid AND connections_id = :connid AND connection_type = :contype", 
                  userid: connection_params[:user_id], connid: connection_params[:connections_id], contype: 1).first_or_create(cp)

    respond_to do |format|
      if @connection.save
 #       format.html { redirect_to @connection, notice: 'Connection was successfully created.' }
        format.json { render json: @connection, status: :created, location: @connection }
      else
 #       format.html { render action: "new" }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /connections/addfriend
  # POST /connections/addfriend.json
  def addfriend
#    logger.debug "Into Connection#addfriend"

    cp = connection_params  # use a copy since original treated as const and can't change

    af = cp[:am_following]
    if (af.nil?)
      cp[:am_following] = 0
    elsif
      cp.merge!( am_following: 0)
    end
    
    fs = cp[:friend_state]
    if (cs.nil?)
      cp[:friend_state] = 1
    elsif
      cp.merge!( friend_state: 1)
    end

    # first, create the connection from "me" to "them"
    @connection = Connection.where("user_id = :userid AND connections_id = :connid", 
                                      userid: connection_params[:user_id], connid: 
                                      connection_params[:connections_id]).first_or_create(cp)
    
    # then see if the connection exists in the other direction as pending (or accepted)
    @recipconnection = Connection.where("user_id = :userid AND connections_id = :connid", 
                                          userid: connection_params[:connections_id], 
                                          connid: connection_params[:user_id])
    if (!@recipconnection.nil?)
      if (@recipconnection.friend_state == 1)
        # reciprocal is waiting for a friend - set up both and go to town...
        cp[:friend_state] = 2
          
        if (!@connection.nil?)
          if (@connection.friend_state < 2)
            @connection.update_attributes(cp)
          end
        end

        cp[:user_id] = @recipconnection.user_id
        cp[:connections_id] = @recipconnection.connections_id
        @recipconnection.update_attributes(cp)

        # send friend accepted APN to both users        
      end
    else
      # no reciprocal connection - send friend invite APN.
      
    end
    
    respond_to do |format|
      if @connection.save
 #       format.html { redirect_to @connection, notice: 'Connection was successfully created.' }
        format.json { render json: @connection, status: :created, location: @connection }
      else
 #       format.html { render action: "new" }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /connections/invite
  # POST /connections/invite.json
  def invite
#    logger.debug "Into Connection#invite"
    # Invite a social contact to join Flux

    respond_to do |format|
#      format.html { redirect_to connections_url }
      format.json { head :no_content }
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

  # DELETE /connections/1
  # DELETE /connections/1.json
  def destroy
    @connection = Connection.find(params[:id])
    @connection.destroy

    respond_to do |format|
#      format.html { redirect_to connections_url }
      format.json { head :no_content }
    end
  end
  
  

  private

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def connection_params
    params.require(:connection).permit(:user_id, :connections_id, :connection_type)
  end
end
