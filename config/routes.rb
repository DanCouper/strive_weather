Rails.application.routes.draw do
  # Defines the root path route ("/"). This shows an overview of all offices.
  root "offices#index"

  #############################################################################
  # NOTE: TEMPORARY DEVELOPMENT ROUTES
  # Debugging for external calls to the Open Weather Map API
  get "weather_api" => "weather_api#index"
  #############################################################################

  # Instead of "/offices/:id", allow "/:id" instead, following the root path.
  get "offices/:id" => "offices#show", as: :office

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
