class ImageMatchesController < ApplicationController
  
    before_filter :authenticate_user_from_token!
    before_filter :authenticate_user!
    authorize_resource
  
    # GET /image/1/matches?auth_token=...
    def getmatches
      @matches = ImageMatch.where({image_id: params[:id]})

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @matches }
      end
    end
    
end