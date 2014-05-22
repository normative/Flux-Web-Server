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
  

#  # from devis/models/confirmable.rb   
#  # Send confirmation instructions by email
#  def send_confirmation_instructions
#    unless @raw_confirmation_token
#      generate_confirmation_token!
#    end
#
#    opts = pending_reconfirmation? ? { :to => unconfirmed_email } : { }
#    send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
#  end

end
