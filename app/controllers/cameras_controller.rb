class CamerasController < ApplicationController
  # GET /cameras
  # GET /cameras.json
  def index
    @cameras = Camera.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cameras }
    end
  end

  # GET /cameras/1
  # GET /cameras/1.json
  def show
    @camera = Camera.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @camera }
    end
  end

  # GET /cameras/new
  # GET /cameras/new.json
  def new
    @camera = Camera.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @camera }
    end
  end

  # GET /cameras/1/edit
  def edit
    @camera = Camera.find(params[:id])
  end

  # POST /cameras
  # POST /cameras.json
  def create
    @camera = Camera.new(camera_params)

    respond_to do |format|
      if @camera.save
        format.html { redirect_to @camera, notice: 'Camera was successfully created.' }
        format.json { render json: @camera, status: :created, location: @camera }
      else
        format.html { render action: "new" }
        format.json { render json: @camera.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cameras/1
  # PATCH/PUT /cameras/1.json
  def update
    @camera = Camera.find(params[:id])

    respond_to do |format|
      if @camera.update_attributes(camera_params)
        format.html { redirect_to @camera, notice: 'Camera was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @camera.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cameras/1
  # DELETE /cameras/1.json
  def destroy
    @camera = Camera.find(params[:id])
    @camera.destroy

    respond_to do |format|
      format.html { redirect_to cameras_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def camera_params
      params.require(:camera).permit(:description, :deviceid, :model, :nickname, :user_id)
    end
end