Rails.application.routes.draw do
  root to: 'admin/users#index'

  namespace :admin do
    root to: "users#index"

    resources :users
  end

  resources :sessions, only: [:new, :create, :destroy]

  get 'about' => 'home#about'
  
  #API
  namespace :api do
    namespace :v0 do
      get 'check' => 'base#check'
      get 'config'  => 'config#index'
      post 'login' => 'sessions#login'
      post  "password/recover" => "forgot_passwords#create"

      resources :users, only: [:show, :update] do
      end
    end
  end
  resource  :recover_password,  only: [:new, :create]
  
  get '*path', to: 'application#render_404', via: :all
end