# frozen_string_literal: true

require 'rack/utils'
require './middleware/files'

module Middleware
  class ErrorRenderer
    def initialize(app, static_error_pages: [404, 500])
      @app = app
      @static_error_pages = static_error_pages
    end

    def call(env)
      status, headers, body = @app.call(env)

      if @static_error_pages.include?(status)
        static_error_response(status)
      else
        [status, headers, body]
      end
    end

    private

    def static_error_response(status)
      file = Middleware::Files.new("public/#{status}.html")

      if file.find
        [
          status,
          { 'Content-Type' => file.mime_type },
          [file.body]
        ]
      else
        [404, {}, [Rack::Utils::HTTP_STATUS_CODES[404]]]
      end
    end
  end
end
