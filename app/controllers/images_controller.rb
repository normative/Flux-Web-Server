class ImagesController < ApplicationController

  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  authorize_resource

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
      mypics = false;
    end
    
    friendpics = params[:friendpics]
    if friendpics.nil?
      friendpics = false;
    end
    
    followingpics = params[:followingpics]
    if followingpics.nil?
      followingpics = false;
    end
  
    @images = Image.filteredmeta(params[:auth_token], params[:lat], params[:long], params[:radius], 
                                params[:altmin], params[:altmax], 
                                params[:timemin], params[:timemax], 
                                params[:taglist], params[:userlist], 
                                mypics, friendpics, followingpics, params[:maxcount])

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
      mypics = false;
    end
    
    friendpics = params[:friendpics]
    if friendpics.nil?
      friendpics = false;
    end
    
    followingpics = params[:followingpics]
    if followingpics.nil?
      followingpics = false;
    end
  
    @images = Image.filteredcontent(params[:auth_token], params[:lat], params[:long], params[:radius], 
                                params[:altmin], params[:altmax], 
                                params[:timemin], params[:timemax], 
                                params[:taglist], params[:userlist], 
                                mypics, friendpics, followingpics, params[:maxcount])

    respond_to do |format|
    #  format.html { render 'index' }
      format.json { render json: @images }
    end
  end
  
  # GET /images/getimagelistforuser?userid=...
  # GET /images/getimagelistforuser.json?userid=...
  def getimagelistforuser
    @images = Image.joins(:user).where(user_id: params[:userid]).select("images.id, users.username, description").order("time_stamp DESC")

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @images }
    end
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
    path = @image.image.path(params[:size])
    if (!path.nil?)
      send_file @image.image.path(params[:size]), disposition: :attachment
    else
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  # GET /images/1/historical
  def historical
    @image = Image.find(params[:id])
    send_file @image.historical.path(params[:size]), disposition: :attachment
  end

  # GET /images/1/renderimage
  def renderimage
    @image = Image.find(params[:id])
    path = @image.historical.path(params[:size])
    if (path.nil?)
      path = @image.image.path(params[:size])
    end
    send_file path, disposition: :attachment
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
        format.html { render action: "new" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
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
                                  :privacy, :historical )
  end
end
