Rails.application.routes.draw do
  resources :hotels, only: [:index, :show]

  get "/" => "hotels#index"
  get "api/search" => "hotels#search_json"
  get "search" => "hotels#search"

  post "hotels/destroy_all"
  post "hotels/load_snapshot"
  post "hotels/load_url"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
