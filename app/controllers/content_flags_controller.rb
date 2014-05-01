class ContentFlagsController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  authorize_resource

  # PUT /images/1/flag?auth_token=...
  # PUT /images/1/flag.json?auth_token=...
  def flag 
    user = User.find_by_authentication_token(params[:auth_token])   
    newflag = { user_id: user[:id], image_id: params[:id] }
      
    @flag = ContentFlag.where(image_id: newflag[:image_id], user_id: newflag[:user_id]).first_or_create(newflag)

    respond_to do |format|
      if @flag.save
        format.html { redirect_to @flag, notice: 'Content flag was successfully created.' }
        format.json { render json: @flag, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @flag.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def flag_params
    params.require(:flag).permit(:user_id, :image_id)
  end
    
end
