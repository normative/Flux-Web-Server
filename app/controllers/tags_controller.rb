class TagsController < ApplicationController
  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/localbyrank?lat=...&long=...&radius=...
  def localbyrank
    @tags = Tag.getlocalbyrank(params[:lat], params[:long], params[:radius])

    respond_to do |format|
      format.html { render 'index' }
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

  # GET /tags/toptwenty?lat=...&long=...&radius=...
  def closest
    @tags = Tag.within(params[:lat], params[:long], params[:radius]).order("created_at DESC").limit(100)
  
    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @tags }
    end
  end
end

