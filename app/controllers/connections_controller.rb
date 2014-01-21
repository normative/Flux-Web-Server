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

  # POST /connections/createfollower
  # POST /connections/createfollower.json
  def createfollowers
    logger.debug "Into Connection#createfollower"

    ct = connection_params[:connection_type]
    if (!ct.nil?)
      connection_params[:connection_type] = 1
    elsif
      connection_params.merge!( connection_type: 1)
    end
    cs = connection_params[:connection_status]
    if (!cs.nil?)
      connection_params[:connection_status] = 2
    elsif
      connection_params.merge!( connection_status: 2)
    end

    @connection = Connection.where("user_id = :userid AND connection_id = :connid AND connection_type = :contype", 
                  userid: connection_params[:user_id], connid: connection_params[:connections_id], contype: 1).first_or_create(connection_params)

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
