class TagsController < ApplicationController
  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.order("tagtext ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/localbyrank?lat=...&long=...&radius=...
  def localbyrank
    @tags = Tag.getlocalbyrank(params[:lat], params[:long], params[:radius], params[:count])

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @tags }
    end
  end
  
  # GET /tags/byrank
  def byrank
    @tags = Tag.getlocalbyrank(0.0, 0.0, 0.0, params[:count])

    respond_to do |format|
      format.html { render 'byrank' }
      format.json { render json: @tags }
    end
  end
  
  # GET /tags/1
  # GET /tags/1.json
  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

end

