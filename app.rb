# frozen_string_literal: true

require 'time'
require './lib/wabi'


require 'pry'

class App < Wabi::Base
  get '/' do
    fresh_when(
      [200, {}, ['Hello world!']],
      etag: 'custom etag',
      cache_control: 'max-age=18000, private',
      last_modified: (Time.new - 360).rfc2822
    )
  end

  get '/about' do
    [200, {}, ['About']]
  end

  post '/google' do
    [201, { 'Location' => 'http://google.com' }, []]
  end

  # mount '/rack_app', NextRackApp
end
