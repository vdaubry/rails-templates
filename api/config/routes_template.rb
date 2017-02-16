Rails.application.routes.draw do
  root :to => 'api/v0/base#check'
  
  #API
  namespace :api do
    namespace :v0 do
      get 'check' => 'base#check'
      
      resources :users
    end
  end
  
  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"
end