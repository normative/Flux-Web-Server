class TwitterClient
  def self.lookup_by_token token
    client = ::Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = token[:access_token]
      config.access_token_secret = token[:access_token_secret]
    end
    client.verify_credentials
  end

  def self.get_friends_by_token token
    client = ::Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = token[:access_token]
      config.access_token_secret = token[:access_token_secret]
    end
    client.friends.to_a    
  end
  
  def self.invite_friend_to_flux params
    client = ::Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = params[:access_token]
      config.access_token_secret = params[:access_token_secret]
    end 
    
    client.create_direct_message params[:friend_id], "I've invited you to try Flux. See what you can discover: smlr.is"
        
  end
  
end
