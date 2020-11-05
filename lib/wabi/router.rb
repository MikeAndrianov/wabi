# frozen_string_literal: true

require 'singleton'

module Wabi
  class Router
    include Singleton

    Route = Struct.new(:http_verb, :path, :response)
    NOT_FOUND_RESPONSE = proc { [404, {}, [Rack::Utils::HTTP_STATUS_CODES[404]]] }

    attr_accessor :routes

    def initialize
      @routes = []
    end

    def add_route(http_verb, path, response)
      @routes << Route.new(http_verb, path, response)
    end

    def find_response(http_verb, path)
      routes
        .find { |route| route.http_verb == http_verb && route.path == path }
        &.response || NOT_FOUND_RESPONSE
    end
  end
end
