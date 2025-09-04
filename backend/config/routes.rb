Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  namespace :users do
    post "signup", to: "registrations#create"
    post "signin",  to: "sessions#create"
    delete "signout", to: "sessions#destroy"
  end

  resources :chat_sessions, only: [ :create ] do
    resources :messages, only: [ :index, :create ], module: :chat_sessions
    resources :suggestions, only: [ :index ], module: :chat_sessions
    post :summarize, on: :member
  end
end
