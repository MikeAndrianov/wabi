# frozen_string_literal: true

require 'rack/test'

require './app'
require './middleware/logger'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
