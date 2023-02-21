Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :managers do
    resources :courses, only: %i[index show edit update destroy] do
      member do
        put :update_enrollments
      end
    end

    resources :activities, only: %i[show]
    resources :school_periods, only: %i[show]
    resources :categories, only: %i[index create]
    resources :locations, only: %i[show]
    resources :coaches

    resources :academies, only: %i[show index] do
      resources :school_periods, only: %i[new create]
      resources :locations, only: %i[create]
    end

    resources :school_periods, only: %i[show] do
      resources :camps, only: %i[new create]
    end

    resources :camps, only: %i[show] do
      resources :activities, only: %i[new create]
    end
  end
end
