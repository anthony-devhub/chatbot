Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :users do
    post 'signup', to: 'registrations#create'
    post 'signin',  to: 'sessions#create'
    delete 'signout', to: 'sessions#destroy'
  end
end
