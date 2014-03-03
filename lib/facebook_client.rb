class FacebookClient
  
  def self.get_friends_by_token token
    user = FbGraph::User.me(token[:access_token])
    if (!user.nil?)
      friends = user.friends
      friends.each do |f|
        if (f.username.nil?)
          u = FbGraph::User.fetch(f.identifier)
          f.username = u.username
        end
      end
      friends.to_a
    else
      Array.new
    end
  end
  
end