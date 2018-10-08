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
      post 'login' => 'sessions#login'
    end
  end
  
  get '*path', to: 'application#render_404', via: :all
end