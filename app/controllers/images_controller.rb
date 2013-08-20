class ImagesController < ApplicationController
  # GET /images
  # GET /images.json
  def index
    @images = params[:ids].present? ? Image.where(id: params[:ids].split(',')) : Image.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @images }
    end
  end

  # GET /images/closest?lat=...&long=...&radius=...
  def closest
    @images = Image.within(params[:lat], params[:long], params[:radius]).limit(100)

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
    send_file @image.image.path(params[:size]), disposition: :attachment
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

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def image_params
      params.require(:image).permit(:altitude, :latitude, :longitude, :pitch, :roll, :yaw, :best_altitude, :best_latitude, :best_longitude, :best_pitch, :best_roll, :best_yaw, :camera_id, :category_id, :description, :heading, :image, :raw_altitude, :raw_latitude, :raw_longitude, :raw_pitch, :raw_roll, :raw_yaw, :user_id)
    end
end
