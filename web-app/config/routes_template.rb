Rails.application.routes.draw do
  root to: 'admin/users#index'

  namespace :admin do
    root to: "users#index"

    resources :users
  end

  #API
  namespace :api do
    namespace :v0 do
      get 'check' => 'base#check'
      get 'config'  => 'config#index'
      post  "password/recover" => "forgot_passwords#create"

      resources :users, only: [:show, :update] do
        collection do
          post 'signin' => 'login#create'
          post 'signup' => 'register#create'
        end 
      end
    end
  end
  
  resource  :recover_password,  only: [:new, :create]
  resources :sessions, only: [:new, :create, :destroy]
  get 'about' => 'home#about'

  
  get '*path', to: 'application#render_404', via: :all
end