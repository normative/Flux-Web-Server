class UserMailer < ActionMailer::Base
  default from: "no-reply@smlr.is", reply_to: "no-reply@flux.smlr.is"
  
#  def validate_email(user)
#    @user = user
#    @url = 'users/' + user.id.to_s + '/validateemail?email_token=12345'
##    @url = '?email_token=12345'
#    @uid = user.id
#    mail(to: @user.email, subject: "Welcome to Flux")
#  end
  
  def invite_email(from_user, to_email)
    @user = from_user
    mail(to: to_email, subject: "Invitation to join Flux", from: 'no-reply@smlr.is').deliver
  end
end
