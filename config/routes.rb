Rails.application.routes.draw do
  root "profiles#index"

  resources :profiles

  namespace :api do
    resources :profiles, only: [:index, :show]
  end
end
