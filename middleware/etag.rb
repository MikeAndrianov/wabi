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

      @fresh_when_options = headers.delete(:fresh_when_options) || {}

      if success?(status) && fresh?(body, request.get_header(NON_MATCH_HEADER))
        [304, headers, []]
      else
        [status, full_response_headers(headers, body), body]
      end
    end

    private

    def success?(status)
      SUCCESS_STATUSES.include?(status)
    end

    def fresh?(new_body, client_etag)
      hashed_payload(new_body) == client_etag
    end

    def full_response_headers(headers, body)
      headers
        .merge(
          Rack::ETAG => hashed_payload(body),
          Rack::CACHE_CONTROL => cache_control_header,
          'Last-Modified' => @fresh_when_options[:last_modified]
        ).compact
    end

    def cache_control_header
      fresh_when_cache_privacy_level = @fresh_when_options[:public]
      return @cache_control if fresh_when_cache_privacy_level.nil?
      return @cache_control.gsub('public', 'private') unless fresh_when_cache_privacy_level

      @cache_control
    end

    def hashed_payload(body)
      @fresh_when_options[:etag] || Digest::SHA256.hexdigest(body[0])
    end
  end
end
