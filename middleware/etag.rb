# frozen_string_literal: true

require 'digest'

module Middleware
  class Etag
    NON_MATCH_HEADER = 'HTTP_IF_NONE_MATCH'

    def initialize(app, cache_control: 'max-age=36000, public')
      @app = app
      @cache_control = cache_control
    end

    def call(env)
      request = Rack::Request.new(env)
      status, headers, body = @app.call(env)

      if success?(status) && fresh?(body, request.get_header(NON_MATCH_HEADER))
        [304, headers, []]
      else
        [
          status,
          headers.merge(
            Rack::ETAG => hashed_body(body),
            Rack::CACHE_CONTROL => @cache_control
          ),
          body
        ]
      end
    end

    private

    def success?(status)
      status == 200 || status == 201
    end

    def fresh?(new_body, client_etag)
      hashed_body(new_body) == client_etag
    end

    def hashed_body(body)
      Digest::SHA256.hexdigest(body[0])
    end
  end
end
