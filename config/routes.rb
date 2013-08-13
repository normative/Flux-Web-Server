Web::Application.routes.draw do
  resources :images do
    collection do
      get 'closest'
    end
    member do
      get 'image'
    end
  end


  resources :categories


  resources :cameras


  resources :users
end
