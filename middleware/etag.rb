# frozen_string_literal: true

require 'digest'

module Middleware
  class Etag
    NON_MATCH_HEADER = 'HTTP_IF_NONE_MATCH'
    SUCCESS_STATUSES = [200, 201].freeze

    def initialize(app, cache_control: 'max-age=36000, public')
      @app = app
      @cache_control = cache_control
    end

    def call(env)
      request = Rack::Request.new(env)
      status, headers, body = @app.call(env)

      if success?(status) && fresh?(headers, body, request.get_header(NON_MATCH_HEADER))
        [304, headers, []]
      else
        [status, full_response_headers(headers, body), body]
      end
    end

    private

    def success?(status)
      SUCCESS_STATUSES.include?(status)
    end

    def fresh?(headers, new_body, client_etag)
      etag = headers[Rack::ETAG] || etag(new_body)

      etag == client_etag
    end

    def full_response_headers(headers, body)
      headers.merge(
        Rack::ETAG => etag(body),
        Rack::CACHE_CONTROL => cache_control(headers)
      )
    end

    def cache_control(headers)
      headers[:cache_control] || @cache_control
    end

    def etag(body)
      Digest::SHA256.hexdigest(body[0])
    end
  end
end
