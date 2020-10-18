# frozen_string_literal: true

require 'rack/test'

require './app'
require './middleware/logger'
require './middleware/static_dispatch'
require './middleware/error_handler'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
