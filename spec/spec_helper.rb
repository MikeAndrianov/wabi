# frozen_string_literal: true

require 'bundler'
Bundler.require

require './app'
require './middleware/logger'
require './middleware/static_dispatch'
require './middleware/error_handler'
require './middleware/error_renderer'
require './middleware/etag'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
