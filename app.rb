# frozen_string_literal: true

require 'time'
require './lib/wabi'
require './second_app'

class App < Wabi::Base
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

  mount '/another', SecondApp
end
