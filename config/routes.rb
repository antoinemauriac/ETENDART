Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :managers do
    resources :academies, except: %i[destroy] do
      resources :school_periods, shallow: true do
        resources :camps, shallow: true do
          resources :activities, shallow: true do
            resources :courses
          end
        end
      end
    end
  end

  namespace :managers do
    resources :courses, only: %i[index show edit update destroy]
  end
end
