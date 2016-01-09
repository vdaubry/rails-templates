Rails.application.routes.draw do
  root :to => 'home#index'
  
  resources :sessions, only: [:new, :create, :destroy]
  
  get 'about' => 'home#about'
end