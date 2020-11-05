# frozen_string_literal: true

require 'rack/utils'
require './middleware/utils/files'

module Middleware
  class StaticDispatch
    PUBLIC_ASSETS_URL = %r{\A/?assets/\w+}.freeze
    MAX_AGE = 31_536_000

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
      if request.get?
        file_path = request.path.gsub('/assets', @folder)

        response = Rack::Response[*generate_static_response(file_path)]
        response.cache!(MAX_AGE)
        response.finish
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
