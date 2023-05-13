  Rails.application.routes.draw do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  authenticated :user, ->(user) { user.manager? } do
    root to: "managers/dashboards#index", as: :manager_root
  end

  authenticated :user, ->(user) { user.coach? } do
    root to: "coaches/dashboards#index", as: :coach_root
  end

  root to: "pages#home"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # import student from csv
  # post '/managers/students/import', to: 'managers/students#import'

  # coach stiumulus controller
  get '/managers/coaches/:category_id/category_coaches', to: 'managers/coaches#category_coaches'

  # création compte coach
  # get 'coaches/change_password/:token', to: 'coaches#change_password', as: :coaches_change_password
  # get 'coaches/change_password/:token', to: 'managers/coaches#change_password', as: :coaches_change_password

  # enrollment stiumulus controller
  get '/managers/enrollments/:academy_id/update_school_periods', to: 'managers/enrollments#update_school_periods'
  get '/managers/enrollments/:school_period_id/update_camps', to: 'managers/enrollments#update_camps'
  get '/managers/enrollments/:camp_id/update_activities', to: 'managers/enrollments#update_activities'


  namespace :managers do
    resources :courses, only: %i[index show edit update destroy] do
      member do
        put :update_enrollments
      end
    end

    post 'import_students', to: 'import_students#import'

    resources :students, only: %i[show new create edit update] do
      member do
        put :update_photo
      end
    end
    resources :feedbacks, only: %i[new create]
    resources :activity_enrollments, only: %i[destroy]
    resources :activities, only: %i[show destroy]
    resources :school_periods, only: %i[show destroy] do
      resources :camps, only: %i[new create]
    end
    resources :categories, only: %i[index create edit update destroy]
    resources :locations, only: %i[show]
    resources :coaches, except: %i[index]
    resources :enrollments, only: %i[new create]

    resources :academies, only: %i[show index] do
      resources :school_periods, only: %i[new create index]
      resources :locations, only: %i[create index edit update]
      resources :students, only: %i[index]
      resources :coaches, only: %i[index]
    end

    resources :camps, only: %i[show destroy] do
      resources :activities, only: %i[new create]
    end

    resources :camps do
      get :export_csv, on: :member
    end
    resources :school_periods do
      get :export_bilan_csv, on: :member
    end
  end

  namespace :coaches do
    resources :courses, only: %i[index show] do
      member do
        put :update_enrollments
      end
    end
    resources :student_profiles, only: %i[show index]
    resources :feedbacks, only: %i[new create]
  end
end
