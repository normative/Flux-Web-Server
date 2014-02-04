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

  # GET /aliases/importcontacts?serviceid=[1|2|3]&access_token=...&access_token_secret=...&maxcount=...&auth_token=...
  # GET /aliases/importcontacts.json?serviceid=[1|2|3]&access_token=...&access_token_secret=...&maxcount=...&auth_token=...
  def importcontacts
    # setup the query but don't execute yet...
    
    contacts = ::TwitterClient.getfriendsbytoken params
    contacts = contacts.sort{|x, y| x.name <=> y.name}
    contactlist = String.new
    contacts.each do |c|
      contactlist << c.name << ','
    end 
    contactlist.chomp!(',') # remove last ',' if exists
    
    query = ::Alias.checkcontacts(params[:auth_token], contactlist, params[:serviceid], params[:maxcount])
    # This will issue a query, but only with the attributes we selected above.
    # It also returns a simple Hash, which is significantly more efficient than a
    # full blown ActiveRecord model.
    results = ActiveRecord::Base.connection.select_all(query)
    results = results.sort{|x, y| x[:flux_id] <=> y[:flux_id]}

    # filter out duplicate flux user ids - pick only the first since it doesn't really matter which...
    uniqresults = Array.new
    lastid = -1
    results.rows.each do |r|
      if r[0] != lastid
      uniqresults << r
        lastid = r[0]
      end
    end

    # now merge two lists based on alias_name and add the profile image URL into the hash...
    uniqresults = uniqresults.sort{|x, y| x[:alias_name] <=> y[:alias_name]}
    c_idx = 0   
    uniqresults.rows.each do |r|
      if r[:alias_name] == contacts[c_idx].name
        r[:image_url] = contacts[c_idx].default_profile_image
      end
      while (contacts[c_idx].name <= r[:alias_name]) && (c_idx < contacts.size) do
        c_idx = c_idx + 1
      end
    end

    # sort by flux username
    uniqresults = uniqresults.sort{|x, y| x[:flux_username] <=> y[:flux_username]}
                      
    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @aliases }
      format.json { render json: uniqresults }
    end
  end

  # POST /aliases
  # POST /aliases.json
  def create
    logger.debug "Into Alias#create"
    
    user = User.find_by_authentication_token(params[:auth_token])
    ap = alias_params
    ap[:user_id] = user[:id]
    
    @alias = Alias.new(ap)

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
