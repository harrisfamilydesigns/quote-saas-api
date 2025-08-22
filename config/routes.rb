Rails.application.routes.draw do
  # Custom Devise routes for API
  devise_for :users, skip: [ :all ]

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'

      # Project resources
      resources :projects do
        resources :material_requests, shallow: true do
          resources :quotes, shallow: true
          # Route for managing supplier invitations
          post 'invite_suppliers', on: :member
          delete 'remove_supplier/:supplier_id', to: 'material_requests#remove_supplier', on: :member
          get 'units', on: :collection
        end
      end

      # Contractor resources
      resources :contractors, only: [ :index, :show ]

      # Supplier resources
      resources :suppliers, only: [ :index, :show ]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
