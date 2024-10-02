# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options host: ENV['BASE_URL'] || 'http://localhost:3000/'
  mount BaseApi => '/api'
  mount GrapeSwaggerRails::Engine => '/swagger' unless Rails.env.production?

  scope :auth do
    get '/line', to: 'line/sessions#new_session'
    match '/line/callback', to: 'line/sessions#callback', via: %i[get post]
    get '/verify-current-user' => 'line/sessions#verify_current_user'
    match '/failure' => 'line/sessions#omniauth_failure', via: %i[get post]
  end
end
