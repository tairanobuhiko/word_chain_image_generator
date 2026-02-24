Rails.application.routes.draw do
  devise_for :users
  get 'games/index'
  get 'games/term_of_service'
  get 'games/privacy_policy'
  post 'games/create', to: 'games#create'
  get 'images/gallery', to: 'images#gallery'
  root to: 'games#index'
  resources :images, only: [:index, :destroy, :show]
  resources :users, only: :show
end
