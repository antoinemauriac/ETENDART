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

  # coach stiumulus controller
  get '/managers/coaches/:category_id/category_coaches', to: 'managers/coaches#category_coaches'
  # enrollment stiumulus controller
  get '/managers/enrollments/:academy_id/update_school_periods', to: 'managers/enrollments#update_school_periods'
  get '/managers/enrollments/:school_period_id/update_camps', to: 'managers/enrollments#update_camps'
  get '/managers/enrollments/:camp_id/update_activities', to: 'managers/enrollments#update_activities'
  # annual_enrollment stimulus controller
  get '/managers/annual_enrollments/:academy_id/update_annual_programs', to: 'managers/annual_enrollments#update_annual_programs'
  get '/managers/annual_enrollments/:annual_program_id/update_activities', to: 'managers/annual_enrollments#update_activities'

  namespace :managers do
    post 'import_students', to: 'import_students#import'
    post 'import_annual_students', to: 'import_annual_students#import'

    resources :courses, only: %i[index show edit update destroy] do
      member do
        put :update_enrollments
        post :unban_student
      end
    end

    resources :students, only: %i[show new create edit update index] do
      member do
        put :update_photo
      end
    end

    resources :activities, only: %i[new create show destroy update] do
      collection do
        get 'new_for_annual'
        post 'create_for_annual'
        get 'show_for_annual'
      end
      member do
        get :all_annual_courses
      end
    end

    resources :school_periods, only: %i[new create index show destroy] do
      member do
        get :statistics
        get :export_bilan_csv
      end
    end

    resources :academies, only: %i[show index] do
      member do
        get :export_absent_students_csv
        get :all_absent_students
      end
    end

    resources :camps, only: %i[new create show destroy] do
      member do
        get :export_students_csv
        get :export_banished_students_csv
      end
    end
    resources :annual_enrollments, only: %i[create]
    resources :feedbacks, only: %i[new create]
    resources :activity_enrollments, only: %i[destroy]
    resources :categories, only: %i[index create edit update destroy]
    resources :locations, only: %i[show]
    resources :coaches
    resources :enrollments, only: %i[new create]
    resources :annual_programs, only: %i[show index new create destroy]
    resources :locations, only: %i[create index edit update]
  end

  namespace :coaches do
    resources :courses, only: %i[index show]
    resources :student_profiles, only: %i[show index]
    resources :feedbacks, only: %i[new create]
  end
end
