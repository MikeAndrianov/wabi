require 'rack/test'

require './app'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
