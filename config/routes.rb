Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "sessions#new"

  get "feed", to: "feeds#index", as: :feed

  resource :session, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :destroy] do
    post :authenticate, on: :collection
  end

  resources :communities, only: [:index, :create, :update] do
    collection do
      get :search
    end

    resources :community_members, only: [:index, :create, :destroy] do
      member do
        patch :promote
        patch :demote
        patch :ban
      end
    end

    resources :messages, only: [:index, :create, :destroy] do
      member do
        post  :reply
        get   :replies
        patch :analyze_sentiment
      end

      resources :reactions, only: [:index, :create, :destroy]
    end
  end


  # API
  namespace :api do
    namespace :v1 do
      resources :communities, only: [:index, :create, :update]
      resources :messages, only: [:index, :create, :destroy]
    end
  end

end
