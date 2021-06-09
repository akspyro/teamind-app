Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # Wicked wizard
  resources :create_team, only: :show
  resources :teams, only: [ :index, :new, :create ] do
    member do
      get :status
    end
  end

  resources :questions, only: [:index, :new] do
    resources :answers, only: [ :create ]
  end
end
