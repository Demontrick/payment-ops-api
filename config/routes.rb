Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :payments, only: [:create, :show]

      resources :operations, only: [:index, :show]

      post "payments/:id/retry", to: "retries#create"

    end
  end
end