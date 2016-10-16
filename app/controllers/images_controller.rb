require 'net/http'
require 'uri'

class ImagesController < ApplicationController

  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!, except: [ :renderimage ]

  # GET /images
  # GET /images.json
  def index
    @images = params[:ids].present? ? Image.where(id: params[:ids].split(',')) : Image.order("time_stamp DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @images }
    end
  end

  # GET /images/filtered?lat=...&long=...&radius=...&minalt=...&maxalt=...
  #                     &mintime=...&maxtime=...
  #                     &taglist="tag1 tag2 tag3...tagN"
  #                     &userlist="user1 user2 user3...userN"
  #                     &catlist="cat1 cat2...catN"
  def filtered
    mypics = params[:mypics]
    if mypics.nil?
      mypics = 0;
    end

    followingpics = params[:followingpics]
    if followingpics.nil?
      followingpics = 0;
    end

    @images = Image.filteredmeta(params[:auth_token], params[:lat], params[:long], params[:radius],
                                params[:altmin], params[:altmax],
                                params[:timemin], params[:timemax],
                                params[:taglist], params[:userlist],
                                mypics, followingpics, params[:maxcount])

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @images }
    end
  end

  # GET /images/filteredcontent?lat=...&long=...&radius=...&minalt=...&maxalt=...
  #                     &mintime=...&maxtime=...
  #                     &taglist="tag1 tag2 tag3...tagN"
  #                     &userlist="user1 user2 user3...userN"
  #                     &catlist="cat1 cat2...catN"
  #                     &maxcount=...
  def filteredcontent
    mypics = params[:mypics]
    if mypics.nil?
      mypics = 0
    end

    followingpics = params[:followingpics]
    if followingpics.nil?
      followingpics = 0
    end

    @images = Image.filteredcontent(params[:auth_token], params[:lat], params[:long], params[:radius],
                                params[:altmin], params[:altmax],
                                params[:timemin], params[:timemax],
                                params[:taglist], params[:userlist],
                                mypics, followingpics, params[:maxcount])

    respond_to do |format|
    #  format.html { render 'index' }
      format.json { render json: @images }
    end
  end

  # GET /images/getimagelistforuser?userid=...
  # GET /images/getimagelistforuser.json?userid=...
  def getimagelistforuser
    @images = Image.joins(:user).where(user_id: params[:userid]).select("images.id, users.username, description, privacy, time_stamp").order("time_stamp DESC")

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @images }
    end
  end

  # GET /images/filteredimgcounts?lat=...&long=...&radius=...&minalt=...&maxalt=...
  #                     &mintime=...&maxtime=...
  #                     &taglist="tag1 tag2 tag3...tagN"
  #                     &userlist="user1 user2 user3...userN"
  #                     &auth_token=...
  def filteredimgcounts
    mypics = params[:mypics]
    if mypics.nil?
      mypics = 0
    end

    followingpics = params[:followingpics]
    if followingpics.nil?
      followingpics = 0
    end

    query = ::Image.filteredimgcounts(params[:auth_token], params[:lat], params[:long], params[:radius],
                                params[:altmin], params[:altmax],
                                params[:timemin], params[:timemax],
                                params[:taglist], params[:userlist],
                                mypics, followingpics)
    # This will issue a query, but only with the attributes we selected above.
    # It also returns a simple Hash, which is significantly more efficient than a
    # full blown ActiveRecord model.
    results = ActiveRecord::Base.connection.select_all(query)
    render json: results
  end


  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/1/image
  def image
    @image = Image.find(params[:id])
    if params[:size] == "binfeatures"
      params[:size] = "original"
      logger.debug 'jumping to features() with size ' + params[:size]
      self.features
    else
      path = @image.image.path(params[:size])

      if (!path.nil?)
        if (Rails.env == 'production') || (Rails.env == 'staging')
           url = @image.image.expiring_url(5, params[:size])
            fn = @image.image_file_name
            ct = @image.image_content_type
          data = open(url)
          send_data data.read, filename: fn, type: ct, disposition: :attachment
        else
          send_file path, disposition: :attachment
        end

  #      send_file @image.image.url(params[:size]), disposition: :attachment

      else
        respond_to do |format|
          format.json { head :no_content }
        end
      end
    end
  end

  # GET /images/1/historical
  def historical
    @image = Image.find(params[:id])
    path = @image.historical.path(params[:size])
    if (!path.nil?)
#      send_file @image.historical.url(params[:size]), disposition: :attachment
      if (Rails.env == 'production') || (Rails.env == 'staging')
         url = @image.historical.expiring_url(5, params[:size])
          fn = @image.historical_file_name
          ct = @image.historical_content_type
        data = open(url)
        send_data data.read, filename: fn, type: ct, disposition: :attachment
      else
        send_file path, disposition: :attachment
      end

    else
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  # GET /images/1/renderimage
  def renderimage

    uri = URI.parse("https://api.clarifai.com/v2/models/d3e9606952c34878b143f3b2f625ca68/outputs")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)

    request.add_field("Authorization", "Bearer ICgn5t1EZkhRuPbH4mO2on0D7h7dZO")
    request.add_field("Content-Type","application/json")

    Rails.logger.info("REQUSTING PREDICTION")
    Rails.logger.info("https://fluxapp.normative.com/images/#{params[:id]}/renderimage?size=oriented")

    data = Hash.new
    data["inputs"] = Array.new
    data["inputs"][0] = Hash.new
    data["inputs"][0]["data"] = Hash.new
    data["inputs"][0]["data"]["image"] = Hash.new
    data["inputs"][0]["data"]["image"]["url"] = "https://fluxapp.normative.com/images/#{params[:id]}/renderimage?size=oriented"
    request.body = data.to_json
    response = http.request(request)
    predictions = JSON.parse(response.body)
    Rails.logger.info(data)
    Rails.logger.info(predictions)
    @image = Image.find(params[:id])
    if predictions.key?("data")
      predictions.data.concepts.each do |concept|
        if concept.value > 0.6
          tag = Tag.create!(:tagtext => concept.name)
          @image.tags << tag
        end
      end
      @image.save
    end


    path = @image.historical.path(params[:size])

    if (path.nil?)
      url = @image.image.expiring_url(5, params[:size])
      fn = @image.image_file_name
      ct = @image.image_content_type
      path = @image.image.path(params[:size])
    else
      url = @image.historical.expiring_url(5, params[:size])
      fn = @image.historical_file_name
      ct = @image.historical_content_type
    end

    if (Rails.env == 'production') || (Rails.env == 'staging')
      #    send_file url, disposition: :attachment
      data = open(url)
      send_data data.read, filename: fn, type: ct, disposition: :attachment
    elsif (!path.nil?)
      send_file path, disposition: :attachment
    else
      respond_to do |format|
        format.json { head :no_content }
      end
    end

  end

  # GET /images/1/features
  def features
    @image = Image.find(params[:id])
    path = @image.features.path(params[:size])
    if (!path.nil?)
      url = @image.features.expiring_url(5, params[:size])
       fn = @image.features_file_name
       ct = @image.features_content_type
     data = open(url)
     send_data data.read, filename: fn, type: ct, disposition: :attachment

    else
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  # GET /images/new
  # GET /images/new.json
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/1/edit
  def edit
    @image = Image.find(params[:id])
  end

  # POST /images
  # POST /images.json
  def create
    logger.debug "Into Images#create"
   @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render json: @image, status: :created, location: @image }
      else
        logger.debug "Image POST failure: " + @image.errors.to_hash(true).to_s
        format.html { render action: "new" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  #PATCH/PUT /images/setprivacy?privacy=<1|0>&imageids=<CSV list of image ids>&auth_token=...
  #PATCH/PUT /images/setprivacy.json?privacy=<1|0>&imageids=<CSV list of image ids>&auth_token=...
  def setprivacy
    @user = User.find_by_authentication_token(params[:auth_token])

    update_attrs = {privacy: params[:privacy]}
    update_ids = params[:image_ids].split(",").map(&:to_i)

    update_ids.each do |uid|
      @image = Image.where({user_id: @user.id, id: uid}).first
      if (!@image.nil?)
        @image.update_attributes(update_attrs)
      end
    end

    respond_to do |format|
      format.json { head :no_content }
    end
 end

#PATCH/PUT /images/setdescription?description=...&auth_token=...
#PATCH/PUT /images/setdescription.json?description=...&auth_token=...
def setdescription
  @user = User.find_by_authentication_token(params[:auth_token])

  update_attrs = {description: params[:description]}
  @image = Image.where({user_id: @user.id, id: params[:id]}).first
  if (!@image.nil?)
    @image.update_attributes(update_attrs)
  end

  respond_to do |format|
    format.json { head :no_content }
  end
end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :no_content }
    end
  end

  # DELETE /images/nuke.json?lat=...&long=...&radius=...
  def nuke
      @images = Image.within(params[:auth_token], params[:lat], params[:long], params[:radius])
#      @images = Image.execute_procedure("imagesinradius", params[:lat], params[:long], params[:radius])
      @images.each do |i|
        i.destroy
      end

    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :no_content }
    end
  end

  #  def filteredmeta
  #    @images = Image.filteredmeta(params[:auth_token], params[:lat], params[:long], params[:radius],
  #                                params[:altmin], params[:altmax],
  #                                params[:timemin], params[:timemax],
  #                                params[:taglist], params[:userlist], params[:catlist], params[:maxcount])
  #
  #    respond_to do |format|
  ##      format.html { render 'index' }
  #      format.json { render json: @images }
  #    end
  #  end

  #  # GET /images/closest?lat=...&long=...&radius=...
  #  def closest
  ##    @images = Image.within(params[:lat], params[:long], params[:radius]).order("created_at DESC").limit(100)
  #    @images = Image.within(params[:lat], params[:long], params[:radius]).limit(100)
  #
  #    respond_to do |format|
  #      format.html { render 'index' }
  #      format.json { render json: @images }
  #    end
  #  end

  #  def filteredtimebucket
  #    @images = Image.filteredtimebucket(params[:lat], params[:long], params[:radius],
  #                                params[:altmin], params[:altmax],
  #                                params[:timemin], params[:timemax],
  #                                params[:taglist], params[:userlist], params[:catlist], params[:maxcount])
  #
  #    respond_to do |format|
  ##      format.html { render 'index' }
  #      format.json { render json: @images }
  #    end
  #  end

  #  def extendedmeta
  #    @images = Image.extendedmeta(params[:idlist]).limit(100)
  #
  #    respond_to do |format|
  ##      format.html { render 'index' }
  #      format.json { render json: @images }
  #    end
  #  end

  private

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def image_params
    params.require(:image).permit(:altitude, :latitude, :longitude, :pitch, :roll, :yaw, :qw, :qx, :qy, :qz,
                                  :raw_altitude, :raw_latitude, :raw_longitude, :raw_pitch, :raw_roll, :raw_yaw,
                                  :raw_qw, :raw_qx, :raw_qy, :raw_qz,
                                  :best_altitude, :best_latitude, :best_longitude, :best_pitch, :best_roll, :best_yaw,
                                  :best_qw, :best_qx, :best_qy, :best_qz,
                                  :camera_id, :category_id, :description, :heading, :image,
                                  :user_id, :time_stamp, :horiz_accuracy, :vert_accuracy,
                                  :privacy, :historical, :features )
  end
end
