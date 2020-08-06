require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  root to: redirect('/admin/transactions')

  resources :admin, only: :index
  namespace :admin do
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end

    resources :transactions, only: [:index, :update]

    get 'transactions/cash_report', to: 'transactions#cash_report'
    get 'transactions/sage_report', to: 'transactions#sage_report'

    resources :teams
    resources :users
    resources :cards
    resources :budget_categories, only: :index
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  as :user do
    get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :transactions do
    get '/categorize', to: 'transactions#categorize'
    patch '/confirm', to: 'transactions#confirm'
    get '/success', to: 'transactions#success'
  end
end
