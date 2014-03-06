class FacebookClient
  
  def self.get_friends_by_token token
    user = FbGraph::User.me(token[:access_token])
    realfriends = Array.new
    if (!user.nil?)
      friends = user.friends
      friends.each do |f|
        if (f.username.nil?)
          u = FbGraph::User.fetch(f.identifier)
          f.username = u.username
        end
        if (!f.username.nil?)
          realfriends << f
        end
      end
    end
    
    realfriends
  end
  
  def self.invite_friend_to_flux token, friendid
    me = FbGraph::User.me(token).fetch
    description = 'Get the Flux app now and join ' + me.name + '.' 
    friend = FbGraph::User.fetch(friendid, access_token: token)
    friend.feed!( message: 'Join me in Flux!', 
                  picture: 'https://graph.facebook.com/denis.delorme.75/picture', 
                     link: 'http://smlr.is', 
                     name: 'Flux', 
              description: description
                )   
  end
  
end