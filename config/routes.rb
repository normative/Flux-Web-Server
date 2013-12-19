Web::Application.routes.draw do
  
  devise_for :users, controllers: { sessions: "users/sessions", passwords: "users/passwords", registrations: "users/registrations" }

  devise_scope :user do
    get 'users/suggestuniqueuname', :to => "users/registrations#suggestuniqueuname"
  end

#  resources :users, only: [ :show, :update, :profile, :edit, :index ] do
  resources :users do
    member do
      get 'profile'
      get 'user'
      get 'avatar'
    end
  end
    
  
  resources :images do
    collection do
      get 'filtered'  # more comprehensive filtering of queries
      get 'filteredmeta'  # set of (base metadata based on filtered image set)
      get 'extendedmeta'  # set of (remainder of metadata not passed in <filteredmeta>, including hash tag list)
      get 'closest'
      get 'filteredcontent' # filtered but returning only lat, lon, alt, imageid, type
      get 'getimagelistforuser'    # returns list of [id, description] pairs, ordered by time_stamp [DESC] with the given userid
#      delete 'nuke'
      get 'nuke'
    end
    member do
      get 'image'
#      destroy 'destroy'
    end
  end


  resources :categories


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
  
end
