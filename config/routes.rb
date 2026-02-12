Rails.application.routes.draw do
  root "profiles#index"

  resources :profiles do
    post :reprocess, on: :member
  end

  namespace :api do
    resources :profiles, only: [:index, :show, :create] do
      post :reprocess, on: :member
    end
  end
end
