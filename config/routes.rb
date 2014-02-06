Web::Application.routes.draw do
  
  devise_for :users, controllers: { sessions: "users/sessions", passwords: "users/passwords", registrations: "users/registrations" }

  devise_scope :user do
    get 'users/suggestuniqueuname', :to => "users/registrations#suggestuniqueuname"
  end

#  resources :users, only: [ :show, :update, :profile, :edit, :index ] do
  resources :users do
    collection do
      get 'lookupname'
      get  'friends',       :to => "connections#friends"
      get  'following',     :to => "connections#following"
      get  'followers',     :to => "connections#followers"
      get  'friendinvites', :to => "connections#friendinvites"
    end
    member do
      get 'profile'
      get 'user'
      get 'avatar'
    end
  end
    
  
  resources :images do
    collection do
      get 'filtered'  # more comprehensive filtering of queries
      get 'filteredcontent' # filtered but returning only lat, lon, alt, imageid, type
      get 'getimagelistforuser'    # returns list of [id, description] pairs, ordered by time_stamp [DESC] with the given userid
      get 'nuke'
#      get 'filteredmeta'  # set of (base metadata based on filtered image set)
#      get 'extendedmeta'  # set of (remainder of metadata not passed in <filteredmeta>, including hash tag list)
#      get 'closest'
#      delete 'nuke'
    end
    member do
      get 'image'
#      destroy 'destroy'
    end
  end


#  resources :categories


  resources :cameras do
    collection do
      get 'lookupbydevid'  # camera that matches specified deviceid
    end
    member do
      get 'camera'
    end
  end


  resources :tags do
    collection do
      get 'localbycountfiltered'
      get 'localbycount'
      get 'bycount'
    end
    member do
      get 'tag'
    end
  end
  
  resources :aliases do
    collection do
      get 'importcontacts'
    end
    member do
      get 'alias'
    end
  end
  
  resources :connections do
    collection do
      post 'follow'
      post 'addfriend'
#      post 'invite'
      put  'disconnect'
      put  'respondtofriend'
#      get  'friends'
#      get  'following'
#      get  'followers'
#      get  'friendinvites'
    end
    member do
    end
  end
  
end
