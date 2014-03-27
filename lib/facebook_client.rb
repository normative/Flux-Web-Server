class FacebookClient
  
  def self.get_friends_by_token token
#    Rails.logger.debug Time.now.to_s + ': facebook_client::get_friends_by_token: start'
    user = FbGraph::User.me(token[:access_token])
    realfriends = Array.new
    if (!user.nil?)
      realfriends = user.friends
      
      # shortcut this to make subsequent processing easier
      realfriends.each do |f|
        f.username = f.identifier
      end
    end

#    Rails.logger.debug Time.now.to_s + ': facebook_client::get_friends_by_token: done'
    realfriends
  end
  
  def self.get_identifier name
    begin
      u = FbGraph::User.fetch(name)
      if (!u.nil?)
        u.identifier
      else
        name
      end
    rescue
      name
    end
  end
  
end