require 'sidekiq/web'

Rails.application.routes.draw do
  RailsAdmin::Engine.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end unless Rails.env.development?
  mount RailsAdmin::Engine => '/theadmin', as: 'rails_admin'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end unless Rails.env.development?
  mount Sidekiq::Web, at: '/theworkers'
end
