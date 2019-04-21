Rails.application.routes.draw do
  devise_for :users

  resources :support_requests, only: [:new, :create]

  root to: 'dashboard#index'
end
