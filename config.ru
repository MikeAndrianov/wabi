# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'logger'
require 'pry'

Bundler.require

require 'time'
require './middleware/logger'
require './middleware/static_dispatch'
require './middleware/error_handler'
require './middleware/error_renderer'
require './middleware/etag'
require './app'
require './second_app'

use Rack::Reloader
use Middleware::Logger, logger: Logger.new($stdout, level: Logger::INFO)
use Middleware::ErrorRenderer
use Middleware::StaticDispatch
use Middleware::ErrorHandler, show_trace: true
use Middleware::Etag


app = App.new

app.routes do
  get '/' do
    fresh_when(
      'Hello world!',
      etag: [1, 'test', { key: :value }],
      cache_control: 'max-age=18000, private',
      last_modified: (Time.new - 360).rfc2822
    )
  end

  get '/about' do
    'About'
  end

  post '/google' do
    status(201)
    headers('Location' => 'http://google.com')

    nil # empty body
  end

  get '/profile/:id' do
    headers('Content-Type' => 'application/json')
    status(201)
    params.to_json
  end

  post '/s/:article_slug/comments/:id' do
    params.keys.join(', ')
  end

  resources :posts, except: %i[edit destroy]

  mount '/another', SecondApp
end

run app
