require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  # Pas besoin d'être authentifié pour accéder aux pages suivantes
  resources :academies, only: %i[index show] do
    resources :school_periods, only: %i[show] do
      resources :activities, only: %i[show] do
        resources :activity_enrollments, only: %i[create]
      end
    end
  end


  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  authenticated :user, ->(user) { user.admin? } do
    root to: "managers/dashboards#index_for_admin", as: :admin_root
  end

  authenticated :user, ->(user) { user.manager? || user.coordinator? } do
    root to: "managers/dashboards#index", as: :manager_root
  end

  authenticated :user, ->(user) { user.coach? } do
    root to: "coaches/dashboards#index", as: :coach_root
  end

  authenticated :user, ->(user) { user.first_login } do
    namespace :users do
      resource :first_login, only: [:show, :update], controller: "users/first_logins"
      root to: "first_logins#show", as: :user_root
    end
  end

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "pages#home"

  namespace :parents do
    resources :children, only: %i[index show new create edit update]
    resource :profile, only: %i[new create show edit update]
  end

  namespace :commerce do
    get 'checkout/success'
    get 'checkout/cancel'
    resource :cart, only: %i[show create update]
    resources :cart_items, only: %i[create destroy]
    resources :orders, only: %i[create show]
  end


  namespace :managers do
    resources :finances, only: %i[index] do
      member do
        get :show_school_period
        get :show_camp
        get :academy_infos
      end
      collection do
        get :membership_finances_overview
        get :export_members_csv
      end
    end

    resources :courses, only: %i[show edit update destroy] do
      member do
        put :update_enrollments
        post :unban_student
      end
    end

    resources :students, only: %i[show new create edit update index] do
      member do
        put :update_photo
        get :current_activities
        get :past_activities
      end
      collection do
        get :index_for_admin
        get :export_students_csv
      end
    end

    resources :activities, only: %i[new create show destroy update] do
      member do
        get :new_for_annual
        post :create_for_annual
        get :show_for_annual
        get :all_annual_courses
        get :export_activity_students
      end
    end

    resources :school_periods, only: %i[new create index show destroy] do
      member do
        get :statistics
      end
      collection do
        get :index_for_admin
      end
    end

    resources :academies, only: %i[show] do
      member do
        get :export_absent_students_csv
        get :export_week_absent_students_csv
        get :today_absent_students
        get :week_absent_students
      end
    end

    resources :camps, only: %i[index new create show destroy] do
      member do
        get :activities
        get :students
        get :payment_details
        get :export_students_csv
        get :export_banished_students_csv
      end
    end

    resources :annual_programs, only: %i[show index new create destroy] do
      member do
        get :statistics
        get :export_past_enrollments
        get :export_annual_students
      end
      collection do
        get :index_for_admin
      end
    end

    resources :coaches do
      member do
        patch :update_infos
      end
    end

    resources :import_students, only: [] do
      collection do
        post :import
        post :import_without_camp
      end
    end

    resources :import_annual_students, only: [] do
      collection do
        post :import
      end
    end

    resources :membership_deposits, only: %i[create index]
    resources :camp_deposits, only: %i[create]
    resources :old_camp_deposits, only: %i[create]
    resources :coach_feedbacks, only: %i[create destroy]
    resources :annual_enrollments, only: %i[create]
    resources :feedbacks, only: %i[create destroy]
    resources :activity_enrollments, only: %i[destroy]
    resources :camp_enrollments, only: %i[index destroy update]
    resources :categories, only: %i[index create edit update destroy]
    resources :enrollments, only: %i[new create]
    resources :locations, only: %i[create show index edit update]
    resources :memberships, only: %i[update create]
  end

  namespace :coaches do
    resources :courses, only: %i[index show]
    resources :student_profiles, only: %i[show index]
    resources :feedbacks, only: %i[new create]
  end

  # coach stiumulus controller
  get '/managers/coaches/:category_id/category_coaches', to: 'managers/coaches#category_coaches'
  # enrollment stiumulus controller
  get '/managers/enrollments/:academy_id/update_school_periods', to: 'managers/enrollments#update_school_periods'
  get '/managers/enrollments/:school_period_id/update_camps', to: 'managers/enrollments#update_camps'
  get '/managers/enrollments/:camp_id/update_activities', to: 'managers/enrollments#update_activities'
  # annual_enrollment stimulus controller
  get '/managers/annual_enrollments/:academy_id/update_annual_programs', to: 'managers/annual_enrollments#update_annual_programs'
  get '/managers/annual_enrollments/:annual_program_id/update_activities', to: 'managers/annual_enrollments#update_activities'
end
