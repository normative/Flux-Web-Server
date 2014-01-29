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
end
