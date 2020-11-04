# frozen_string_literal: true

require 'singleton'

module Wabi
  class Router
    include Singleton

    Route = Struct.new(:http_verb, :path, :response)

    attr_accessor :routes

    def initialize
      @routes = []
    end

    def add_route(http_verb, path, response)
      @routes << Route.new(http_verb, path, response)
    end

    def find_response(http_verb, path)
      @routes
        .find { |route| route.http_verb == http_verb && route.path == path }
        .response
    end
  end
end
