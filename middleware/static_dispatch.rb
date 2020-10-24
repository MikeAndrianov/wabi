# frozen_string_literal: true

require 'rack/utils'
require './middleware/utils/files'

module Middleware
  class StaticDispatch
    PUBLIC_ASSETS_URL = %r{\A/?assets/\w+}.freeze

    def initialize(app, folder: 'public')
      @app = app
      @folder = folder
    end

    def call(env)
      request = Rack::Request.new(env)

      if PUBLIC_ASSETS_URL.match?(request.path)
        handle_asset_request(request)
      else
        @app.call(env)
      end
    end

    private

    def handle_asset_request(request)
      file_path = request.path.gsub('/assets', @folder)

      if request.get?
        generate_static_response(file_path)
      else
        [400, {}, [Rack::Utils::HTTP_STATUS_CODES[400]]]
      end
    end

    def generate_static_response(path)
      file = Utils::Files.new(path)

      if file.find
        [
          200,
          { 'Content-Type' => file.mime_type },
          [file.body]
        ]
      else
        [404, {}, [Rack::Utils::HTTP_STATUS_CODES[404]]]
      end
    end
  end
end
