Web::Application.routes.draw do

  resources :images do
    collection do
      get 'filtered'  # more comprehensive filtering of queries
      get 'filteredmeta'  # set of (base metadata based on filtered image set)
      get 'extendedmeta'  # set of (remainder of metadata not passed in <filteredmeta>, including hash tag list)
      get 'closest'
      get 'content'       # filtered but returning only lat, lon, alt, imageid, type
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


  resources :users


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
