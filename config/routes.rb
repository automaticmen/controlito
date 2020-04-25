Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "users#index"
  resources :users, only:[:index]
  resources :sessions, only:[:create]
  resources :writers
  resources :fiverr_orders
  resources :articles
  get "fiverr_orders/show" => "fiverr_orders#show"
  get "log_out" => "sessions#destroy"
end
