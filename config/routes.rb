Rails.application.routes.draw do
  root to: ->(env) { ['200', {}, ['Freeng API']] }

  post '/login', to: 'authentication#login'

  defaults(format: :json) do
    resources :posts, only: [:index, :create, :show, :destroy]
    resources :images, only: [:create]
  end
end
