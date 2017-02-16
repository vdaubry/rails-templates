Rails.application.routes.draw do
  root :to => 'home#index'
  
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