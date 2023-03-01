Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations", passwords: 'devise/passwords' }

  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/managers/students/import', to: 'managers/students#import'
  get '/managers/coaches/:categoryId/category_coaches', to: 'managers/coaches#category_coaches'

  get '/managers/enrollments/:academy_id/update_school_periods', to: 'managers/enrollments#update_school_periods'
  get '/managers/enrollments/:school_period_id/update_camps', to: 'managers/enrollments#update_camps'
  get '/managers/enrollments/:camp_id/update_activities', to: 'managers/enrollments#update_activities'

  get 'coaches/change_password/:token', to: 'coaches#change_password', as: :coaches_change_password

  namespace :managers do
    resources :courses, only: %i[index show edit update destroy] do
      member do
        put :update_enrollments
      end
    end

    resources :students, only: %i[index show new create]
    resources :activities, only: %i[show destroy]
    resources :school_periods, only: %i[show]
    resources :categories, only: %i[index create edit update destroy]
    resources :locations, only: %i[show]
    resources :coaches
    resources :enrollments, only: %i[new create]

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

  namespace :coaches do
    resources :courses, only: %i[index show] do
      member do
        put :update_enrollments
      end
    end
    resources :student_profiles, only: %i[show]
    resources :feedbacks, only: %i[new create]
  end
end
