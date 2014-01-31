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

  # POST /connections/follow
  # POST /connections/follow.json
  def follow
#    logger.debug "Into Connection#follow"

    cp = connection_params  # use a copy since original treated as const and can't change

    ct = connection_params[:connection_type]
    if (ct.nil?)
      cp[:connection_type] = 1
    elsif
      cp.merge!( connection_type: 1)
    end
    
    cs = cp[:state]
    if (cs.nil?)
      cp[:state] = 2
    elsif
      cp.merge!( state: 2)
    end

#    logger.debug cp

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

    cs = cp[:state]
    if (cs.nil?)
      cp[:state] = 4
    elsif
      cp.merge!( state: 4)
    end

    # first, see if the connection exists in the other direction as pending (or accepted)
    @recipconnection = Connection.where("user_id = :userid AND connections_id = :connid", 
    userid: connection_params[:connections_id], connid: connection_params[:user_id])
    if (@recipconnection)
      if (@recipconnection.state == 3)
        # reciprocal is waiting for a friend - set up both and go to town...
        @connection = Connection.where("user_id = :userid AND connections_id = :connid", 
                      userid: connection_params[:user_id], connid: connection_params[:connections_id]).first_or_create(cp)
        if (!@connection.nil?)
          # check state and update if necessary
          if (@connection.state < 4)
            @connection.update_attributes(cp)
          end
        end

        cp[:user_id] = @recipconnection.user_id
        cp[:connections_id] = @recipconnection.connections_id
        cp[:state] = 4  
        @recipconnection.update_attributes(cp)
        
      end
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
