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
  
  # GET /connections/friendinvites
  # GET /connections/friendinvites.json
  def friendinvites
    @connections = Connection.getfriendinvites(params[:auth_token])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @connections }
    end
  end

  # POST /connections?auth_token=...
  # POST /connections.json?auth_token=...
  def create
    ct = connection_params[:connection_type].to_i
    if (!ct.nil?)
      if (ct == 1)     # follow
        self.localfollow connection_params
      elsif (ct == 2)  #friend
        self.localaddfriend connection_params
      else
        respond_to do |format|
          format.json { render json: {error_message: "invalid connection type"}, status: :unprocessable_entity }           
        end
      end
    else
      respond_to do |format|
        format.json { render json: {error_mesage: "missing connection type"}, status: :unprocessable_entity }           
      end
    end
  end
  
    
  # POST /connections/follow
  # POST /connections/follow.json
  def follow
    self.localfollow connection_params
  end
  
  def localfollow connparam
#    logger.debug "Into Connection#follow"

    if connparam.nil?
      connparam = connection_params  # grab a copy of the hash from the function
    end
    
    cp = connparam.except(:connection_type)

    af = cp[:am_following]
    if (af.nil?)
      cp[:am_following] = 1
    elsif
      cp.merge!( am_following: 1)
    end
    
    fs = cp[:friend_state]
    if (fs.nil?)
      cp[:friend_state] = 0
    elsif
      cp.merge!( friend_state: 0)
    end

    @connection = Connection.where("user_id = :userid AND connections_id = :connid", 
                                    userid: connparam[:user_id], 
                                    connid: connparam[:connections_id]).first_or_create(cp)

    # may need to update if the record already exists                    
    if (!@connection.nil?)
      if (@connection.am_following != 1)
        cp.merge!( friend_state: @connection.friend_state)
        @connection.update_attributes(cp)
      end
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

  # POST /connections/addfriend
  # POST /connections/addfriend.json
  def addfriend
    self.localaddfriend connection_params
  end
  
  def localaddfriend connparam
#    logger.debug "Into Connection#addfriend"

    if connparam.nil?
      connparam = connection_params  # grab a copy of the hash from the function
    end
        
    cp = connparam.except(:connection_type)

    af = cp[:am_following]
    if (af.nil?)
      cp[:am_following] = 0
    elsif
      cp.merge!( am_following: 0)
    end
    
    fs = cp[:friend_state]
    if (fs.nil?)
      cp[:friend_state] = 1
    elsif
      cp.merge!( friend_state: 1)
    end

    # first, create the connection from "me" to "them"
    @connection = Connection.where("user_id = :userid AND connections_id = :connid", 
                                      userid: connparam[:user_id], 
                                      connid: connparam[:connections_id]).first_or_create(cp)
    
    # then see if the connection exists in the other direction as pending (or accepted)
    @recipconnection = Connection.where("user_id = :connid AND connections_id = :userid", 
                                          userid: connparam[:user_id], 
                                          connid: connparam[:connections_id]).first()
                                            
    cp = cp.except(:am_following)

    needtoinvite = false
    
    if (!@recipconnection.nil?)
      if (@recipconnection.friend_state == 1)
        # reciprocal is waiting for a friend - set up both and go to town...
        cp[:friend_state] = 2
          
        if (!@connection.nil?)
          if (@connection.friend_state != 2)
            @connection.update_attributes(cp)
            logger.debug("Send friend accepted to me")
          end
        end

        cp[:user_id] = @recipconnection[:user_id]
        cp[:connections_id] = @recipconnection[:connections_id]
        @recipconnection.update_attributes(cp)
#        @recipconnection.save

        # send friend accepted APN to both users        
        logger.debug("Send friend accepted to both users")
      elsif (@recipconnection.friend_state == 0)
        needtoinvite = true
      end
    else
      needtoinvite = true
    end
    
    if needtoinvite == true
      # send friend invite APN.
      if (!@connection.nil?)
        if (@connection.friend_state != 1)
          @connection.update_attributes(cp)
        end
      end
      logger.debug("Send friend invite")
      
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

  
  # PUT /connections/respondtofriend?
  # PUT /connections/respondtofriend.json
  def respondtofriend
#    @connection = Connection.find(params[:id])
              
    if (!connection_params[:friend_state].nil?)
      if (connection_params[:friend_state].to_i > 0)
        conparam = Hash.new
        conparam[:user_id] = connection_params[:user_id]
        conparam[:connections_id] = connection_params[:connections_id]
          
        self.localaddfriend conparam 
        
      else
        # find the requesting (reciprocal) connection
        @connection = Connection.where("user_id = :connid AND connections_id = :userid", 
                                          userid: connection_params[:userid], 
                                          connid: connection_params[:connections_id]).first

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
    else
      respond_to do |format|
        format.json { render json: {error_message: "missing friend_state"}, status: :unprocessable_entity }
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

    ct = params[:connection_type].to_i
    if (ct.nil?)
      ct = 3
    end

    cp = Hash.new
    if (ct == 2) || (ct == 3)
      cp[:friend_state] = 0
      if (@connection.friend_state == 2)
        @recipconnection = Connection.where("user_id = :connid AND connections_id = :userid", 
                                              userid: @connection.user_id, 
                                              connid: @connection.connections_id).first()
        if (!@recipconnection.nil?)
          @recipconnection.update_attributes(cp)
        end
      end
    end
    
    if (ct == 1) || (ct == 3)
      cp[:am_following] = 0
    end
        
    respond_to do |format|
      if @connection.update_attributes(cp)
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
    params.require(:connection).permit(:user_id, :connections_id, :connection_type, :friend_state)
  end
end
