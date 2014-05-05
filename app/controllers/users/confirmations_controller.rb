class Users::ConfirmationsController < Devise::ConfirmationsController

  def emailconfirmed
    respond_to do |format|
      format.html # confirmed.html.erb
    end
  end
  
  protected
    # The path used after confirmation.
    def after_confirmation_path_for(resource_name, resource)
#      logger.debug "redirecting after confirmation path to http://smlr.is"
#      "http://smlr.is"
      "/users/emailconfirmed"
   end
  
end