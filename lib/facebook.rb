# http://www.simple10.com/devise-omniauth-facebook-api-hacks/

module OAuth2
  class Facebook < Client
    def initialize(key, secret, opts = {})
      opts[:site] = 'https://graph.facebook.com/'
      super(key, secret, opts)
    end

    def self.lookup_by_token token
      token = OAuth2::AccessToken.new(new('', ''), token)
      JSON.parse(token.get('/me').body)
    end
  end
end
