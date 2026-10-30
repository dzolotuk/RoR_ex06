Rails.application.routes.draw do
  devise_for :users
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'products#index'
  resources :products, only: %i[index show]
  resources :brands, only: %i[index show]

  resource :cart, only: %i[show destroy]
  resources :cart_items, only: %i[create destroy] do
    member do
      patch :increase
      patch :decrease
    end
  end
  resources :orders, only: %i[create show]

  # Any other address typed by hand goes back to the root page with a message.
  # (not the files like favicon.ico, nor the internal pages of Rails)
  get '*unknown', to: 'pages#missing',
                  constraints: ->(request) { File.extname(request.path).empty? && !request.path.start_with?('/rails') }
end
