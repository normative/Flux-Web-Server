Web::Application.routes.draw do

#    resources :sessions, :constraints => { :protocol => "https" }
#  end
#  Or if you need to force SSL for multiple routes:
#  
#  MyApplication::Application.routes.draw do
  get "content_flags/new"
#    scope :constraints => { :protocol => "https" } do 
#      # All your SSL routes.
#    end
#  end
 
#  scope :constraints => { :protocol => "https" } do   
    devise_for :users, controllers: { sessions: "users/sessions", 
                                      passwords: "users/passwords", 
                                      confirmations: "users/confirmations",
                                      registrations: "users/registrations" 
                                    }

    devise_scope :user do
      get 'users/suggestuniqueuname', :to => "users/registrations#suggestuniqueuname"
    end

#  resources :users, only: [ :show, :update, :profile, :edit, :index ] do
    resources :users do
      collection do
        get 'lookupname'
  #      get 'friends',       :to => "connections#friends"
        get 'following',     :to => "connections#following"
        get 'followers',     :to => "connections#followers"
        get 'followerrequests', :to => "connections#followerrequests"
        put 'updateapnstoken'
        put 'invitetoflux'
      end
      member do
        get 'profile'
        get 'user'
        get 'avatar', :protocol => "http"
#        get 'validateemail'
      end
    end
  
    resources :images do
      collection do
        get 'filtered'  # more comprehensive filtering of queries
        get 'filteredcontent' # filtered but returning only lat, lon, alt, imageid, type
        get 'filteredimgcounts'      # returns total image count, count of my images, count of friends images and count of following images 
        get 'getimagelistforuser'    # returns list of [id, description] pairs, ordered by time_stamp [DESC] with the given userid
        get 'nuke'
        put 'setprivacy'
        patch 'setprivacy'
      end
      member do
        get 'image', :protocol => "http"
        get 'renderimage', :protocol => "http"
        get 'historical', :protocol => "http"
        get 'features', :protocol => "http"
        get 'matches',  :to => "image_matches#getmatches"   # return set of image match records for the specified image
        put 'flag', :to => "content_flags#flag"
      end
    end
  
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
        get 'foruser'
      end
      member do
        get 'alias'
      end
    end
    
    resources :connections do
      collection do
        post 'follow'
        put  'disconnect'
        put  'respondtofollowrequest'
      end
      member do
      end
    end
#  end    
  
#  resources :image_matches do
#    collection do
#    end
#    member do
#      get 'matches'
#    end
#  end

end
