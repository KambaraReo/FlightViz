Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  namespace :api do
    namespace :v1 do
      get 'flights/available_dates', to: 'tracks#available_dates'
      get 'flights', to: 'tracks#flight_ids'
      get 'flights/:flight_id/track', to: 'tracks#flight_track'
      resources :airports, only: [:index]
    end
  end
end
