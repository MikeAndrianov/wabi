# frozen_string_literal: true

require 'singleton'
require_relative 'route'
require_relative 'mount_route'

module Wabi
  class Router
    include Singleton

    attr_accessor :routes

    def initialize
      @routes = []
      @mount_routes = []
    end

    def add_route(http_verb, path, response)
      @routes << Route.new(http_verb, path, response)
    end

    def add_mount_route(path, mount_class)
      @mount_routes << MountRoute.new(path, mount_class)
    end

    def find_route(http_verb, path)
      mount_route = @mount_routes.find { |route| path.start_with?(route.path) }
      return mount_route if mount_route

      routes.find { |route| matching_route?(route, http_verb, path) }
    end

    private

    def matching_route?(route, http_verb, path)
      return false unless route.http_verb == http_verb

      route_path = route.path
      splitted_route_path = route_path.split('/')

      if splitted_route_path.any? { |path_chunk| path_chunk.include?(':') }
        regex = Regexp.new(route_path.gsub(/:\w+/, '\w+'))

        path.match?(regex)
      else
        route.path == path
      end
    end
  end
end
