class Users::ConfirmationsController < Devise::ConfirmationsController

  protected
    # The path used after confirmation.
    def after_confirmation_path_for(resource_name, resource)
#      logger.debug "redirecting after confirmation path to http://smlr.is"
      "http://smlr.is"
    end
  
end