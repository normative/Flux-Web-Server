class ProfilesController < ApplicationController

#  before_filter :authenticate_user_from_token!
#  before_filter :authenticate_user!
#  authorize_resource

  # GET /users/profile/1.json
   def fetch
#     def self.getprofile auth, userid
#       select("*").from("getprofileforuser('#{auth}', #{userid})")     
#     end
     #    @profile = User.getprofile(params[:auth_token], params[:id])
 
     # setup the query but don't execute yet...
#     query = ::User.getprofile(params[:auth_token], params[:id])
     # This will issue a query, but only with the attributes we selected above.
     # It also returns a simple Hash, which is significantly more efficient than a
     # full blown ActiveRecord model.
#     results = ActiveRecord::Base.connection.select_all(query)
     #=> [{"id" => 1, "member_since" => 2013-02-26 01:28:08 UTC}, etc...]    
#     render json: results
     return
   end
  
end
