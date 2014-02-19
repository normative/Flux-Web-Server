class TagsController < ApplicationController

  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  authorize_resource

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.order("tagtext ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/localbycountfiltered?lat=...&long=...&radius=...
  def localbycountfiltered
    mypics = params[:mypics]
    if mypics.nil?
      mypics = 0;
    end
    
    friendpics = params[:friendpics]
    if friendpics.nil?
      friendpics = 0;
    end
    
    followingpics = params[:followingpics]
    if followingpics.nil?
      followingpics = 0;
    end
  
    @tags = Tag.getlocalbycountfiltered(params[:auth_token], params[:lat], params[:long], params[:radius], 
                                params[:altmin], params[:altmax], 
                                params[:timemin], params[:timemax], 
                                params[:taglist], params[:userlist], 
                                mypics, friendpics, followingpics, params[:maxcount])
    respond_to do |format|
      format.html { render 'bycount' }
      format.json { render json: @tags }
    end
  end
  
  # GET /tags/localbycount?lat=...&long=...&radius=...
  def localbycount
    @tags = Tag.getlocalbycount(params[:lat], params[:long], params[:radius], params[:maxcount])

    respond_to do |format|
      format.html { render 'bycount' }
      format.json { render json: @tags }
    end
  end
  
  # GET /tags/bycount
  def bycount
    @tags = Tag.getlocalbycount(0.0, 0.0, 0.0, params[:maxcount])

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


