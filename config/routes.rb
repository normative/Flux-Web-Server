Web::Application.routes.draw do

  devise_for :users, controllers: { sessions: "users/sessions", passwords: "users/passwords", registrations: "users/registrations" }

  resources :images do
    collection do
      get 'filtered'  # more comprehensive filtering of queries
      get 'filteredmeta'  # set of (base metadata based on filtered image set)
      get 'extendedmeta'  # set of (remainder of metadata not passed in <filteredmeta>, including hash tag list)
      get 'closest'
      get 'filteredcontent' # filtered but returning only lat, lon, alt, imageid, type
#      delete 'nuke'
      get 'nuke'
    end
    member do
      get 'image'
#      destroy 'destroy'
    end
  end


  resources :categories


  resources :cameras


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
