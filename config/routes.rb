Rails.application.routes.draw do
  resources :customizations
  devise_for :users, controllers: {
    registrations: 'registrations'
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'industry_data#index'

  #SIDEKIQ
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :customer_machines

  resources :industry_data, only: [:index] do
    collection do
      get :sent_all
    end
  end

  resources :logs, only: :index

  resources :notifications, only: [:index] do
    collection do
      patch :set_all_read
    end
    member do
      patch :set_read
    end
  end

  resources :roles

  resources :users do
    member do
      patch 'toggle_role/:role', action: :toggle_role, as: :toggle_role
    end
  end
end
