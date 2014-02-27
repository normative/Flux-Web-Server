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
    logger.debug "Into Alias#importcontacts"
        
    contactlist = String.new
    contacts = Array.new
    
    service_id = params[:serviceid].to_i

    if (service_id == 1)
      # email contacts...
      logger.debug "service id = 1 (email contacts)"
      respond_to do |format|
        format.json { head :no_content }
      end
      return
    elsif (service_id == 2)
      # Twitter..
      logger.debug "service id = 2 (twitter contacts)"
      contacts = ::TwitterClient.get_friends_by_token params
      contacts = contacts.sort{|x, y| x.username <=> y.username}
      contacts.each do |c|
        contactlist << c.username << ','
      end 
      contactlist.chomp!(',') # remove last ',' if exists
    elsif (service_id == 3)
      # Facebook...
      logger.debug "service id = 3 (Facebook contacts)"
      respond_to do |format|
        format.json { head :no_content }
      end
      return
    else
      # unknown - fail...
      respond_to do |format|
        format.json { head :no_content }
      end
      return
    end
    
       
    query = ::Alias.checkcontacts(params[:auth_token], contactlist, service_id, 0)
    # This will issue a query, but only with the attributes we selected above.
    # It also returns a simple Hash, which is significantly more efficient than a
    # full blown ActiveRecord model.
    results = ActiveRecord::Base.connection.select_all(query)
    results = results.sort{|x, y| x["user_id"] <=> y["user_id"]}

    # filter out duplicate flux user ids - pick only the first since it doesn't really matter which...
    uniqresults = Array.new
    lastid = -1
    if (results.size > 0)
      results.each do |r|
        if r[0] != lastid
          uniqresults << r
          lastid = r[0]
        end
      end
    end

    # now merge two lists based on alias_name and add the profile image URL into the hash...
    uniqresults = uniqresults.sort{|x, y| x["alias_name"].to_s <=> y["alias_name"].to_s}
    c_idx = 0   
    newrows = Array.new
    if (uniqresults.size > 0)
      uniqresults.each do |r|
        if (service_id == 1)
          # email contacts...
        elsif (service_id == 2)
          # Twitter contacts...
          while (c_idx < contacts.size) && (contacts[c_idx].username.to_s < r["alias_name"].to_s)  do
            if (contacts[c_idx].username != r["alias_name"])
              # add rows to something to add into r later...
              nr = {alias_name: contacts[c_idx].username, profile_pic_URL: contacts[c_idx].profile_image_uri.to_s,
                      display_name: contacts[c_idx].name,
                      user_id: 0, username: '', am_follower: 0, is_following: 0, friend_state: 0}
              newrows << nr
            end
            c_idx = c_idx + 1
          end

          if (c_idx < contacts.size) && (r["alias_name"].to_s == contacts[c_idx].username.to_s)
            nr = {alias_name: r["alias_name"],
                    display_name: contacts[c_idx].name,
                    profile_pic_URL: '',
                    user_id: r["user_id"], username: r["username"], 
                    am_follower: r["am_follower"], is_following: r["is_following"], friend_state: r["friend_state"]}
            if (contacts[c_idx].profile_image_uri?)
              nr[:profile_pic_URL] = contacts[c_idx].profile_image_uri.to_s
            end
            newrows << nr
            c_idx = c_idx + 1
          end
          
        elsif (service_id == 3)
          # Facebook
        end
      end
      
      # now do the rest in the contacts list...
      if (service_id == 1)
        # email contacts...
      elsif (service_id == 2)
        # Twitter contacts...
        while (c_idx < contacts.size)  do
          # add rows to something to add into r later...
          nr = {alias_name: contacts[c_idx].username, profile_pic_URL: contacts[c_idx].profile_image_uri.to_s,
                  display_name: contacts[c_idx].name,
                  user_id: 0, username: '', am_follower: 0, is_following: 0, friend_state: 0}
          newrows << nr
          c_idx = c_idx + 1
        end
      end      
      
    elsif (contacts.size > 0)
      contacts.each do |c|
        nr = {alias_name: c.username, profile_pic_URL: c.profile_image_uri.to_s,
                  display_name: c.name,
                  user_id: 0, username: '', am_follower: 0, is_following: 0, friend_state: 0}
        newrows << nr
      end
    end

    # add in the new rows...
    finalresults = newrows
    
    # sort by alias_name
    finalresults = finalresults.sort{|x, y| x[:alias_name] <=> y[:alias_name]}
                      
    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @aliases }
      format.json { render json: finalresults }
    end
  end

  # GET /aliases/foruser?auth_token=
  def foruser
    user = User.find_by_authentication_token(params[:auth_token])
    @aliases = Alias.where(user_id: user[:id])
      
    respond_to do |format|
#      format.html # show.html.erb
      format.json { render json: @aliases }
    end
  end
  
  # POST /aliases
  # POST /aliases.json
  def create
    logger.debug "Into Alias#create"
    
    user = User.find_by_authentication_token(params[:auth_token])
    ap = alias_params
    ap[:user_id] = user[:id]
    
    @alias = Alias.where(user_id: ap[:user_id], alias_name: ap[:alias_name], service_id: ap[:service_id]).first_or_create(ap)

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
