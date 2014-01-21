class AliasesController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  authorize_resource

  # GET /aliases
  # GET /aliases.json
  def index
    @aliases = params[:ids].present? ? Alias.where(id: params[:ids].split(','))  : Alias.order("user_id DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @aliases }
    end
  end

  # GET /aliases/1
  # GET /aliases/1.json
  def show
    @alias = Alias.find(params[:id])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @alias }
    end
  end

  # GET /aliases/check_contacts
  # GET /aliases/check_contacts.json?contacts=[[id, service],[id, service]...]
  def checkcontacts
    @aliases = Array.new
    
    contactstrs = params[:contacts].split(" ")
    contactstrs.each{|contactstr|
      contact = contactstr.split(",")
      # find contact in db, return fluxID
      @alias = Alias.select(:user_id, :alias_name, :service_id).where("alias_name = :alname AND service_id = :servid", alname: contact[0], servid: contact[1]).take
      if !(@alias.nil?)
#        alias_ray = {user_id: @alias.user_id, alias_name: @alias.alias_name, service_id: @alias.service_id} 
#        @aliases << alias_ray
        @aliases << {user_id: @alias.user_id}
      elsif
        puts "alias = NIL" 
      end
    }
    
@aliases = @aliases.sort{|x, y| x[:user_id] <=> y[:user_id]}.uniq
#    @aliases = check_contacts(params[:auth_token], params[:contactlist], params[:maxcount])

    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @aliases }
    end
  end

  # POST /aliases
  # POST /aliases.json
  def create
    logger.debug "Into Alias#create"
   @alias = Alias.new(alias_params)

    respond_to do |format|
      if @alias.save
 #       format.html { redirect_to @alias, notice: 'Alias was successfully created.' }
        format.json { render json: @alias, status: :created, location: @alias }
      else
 #       format.html { render action: "new" }
        format.json { render json: @alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aliases/1
  # PATCH/PUT /aliases/1.json
  def update
    @alias = Alias.find(params[:id])

    respond_to do |format|
      if @alias.update_attributes(alias_params)
 #       format.html { redirect_to @alias, notice: 'Alias was successfully updated.' }
        format.json { head :no_content }
      else
 #       format.html { render action: "edit" }
        format.json { render json: @alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aliases/1
  # DELETE /aliases/1.json
  def destroy
    @alias = Alias.find(params[:id])
    @alias.destroy

    respond_to do |format|
#      format.html { redirect_to aliases_url }
      format.json { head :no_content }
    end
  end
  
  

  private

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def alias_params
    params.require(:alias).permit(:user_id, :alias_name, :service_id )
  end
end
