Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :work_requests, only: [:index, :show, :create, :destroy]
    end
  end
end
