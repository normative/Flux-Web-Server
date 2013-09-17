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

  # GET /tags/localbycount?lat=...&long=...&radius=...
  def localbycount
    @tags = Tag.getlocalbycount(params[:lat], params[:long], params[:radius], params[:maxrows])

    respond_to do |format|
      format.html { render 'bycount' }
      format.json { render json: @tags }
    end
  end
  
  # GET /tags/bycount
  def bycount
    @tags = Tag.getlocalbycount(0.0, 0.0, 0.0, params[:maxrows])

    respond_to do |format|
      format.html { render 'bycount' }
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

