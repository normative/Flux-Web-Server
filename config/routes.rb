Web::Application.routes.draw do

  resources :images do
    collection do
      get 'filtered'  # more comprehensive filtering of queries
      get 'filteredmeta'  # set of (base metadata based on filtered image set)
      get 'extendedmeta'  # set of (remainder of metadata not passed in <filteredmeta>, including hash tag list)
      get 'closest'
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
      get 'localbyrank'
      get 'byrank'
    end
    member do
      get 'tag'
    end
  end
  
end
