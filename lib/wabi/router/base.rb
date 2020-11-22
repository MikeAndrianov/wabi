# frozen_string_literal: true

require 'singleton'
require_relative 'route'
require_relative 'mount_route'
require_relative 'resources_route'

module Wabi
  module Router
    class Base
      include Singleton

      attr_accessor :routes, :mount_routes, :resources_routes

      def initialize
        @routes = []
        @mount_routes = []
        @resources_routes = []
      end

      def add_route(http_verb, path, response)
        @routes << Route.new(http_verb, path, response)
      end

      def add_mount_route(path, mount_class)
        @mount_routes << MountRoute.new(path, mount_class)
      end

      def add_resources_route(resource_plural_name, except)
        @resources_routes << ResourcesRoute.new(resource_plural_name, except)
      end

      def find_route(http_verb, path)
        mount_route = @mount_routes.find { |route| path.start_with?(route.path) }
        return mount_route if mount_route

        (routes + resources_routes).find { |route| route.match?(http_verb, path) }
      end
    end
  end
end
