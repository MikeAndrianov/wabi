# frozen_string_literal: true

require 'singleton'

module Wabi
  class MountRoute
    attr_reader :path

    def initialize(path, mount_class)
      @path = path
      @mount_class = mount_class
      @app = @mount_class.new
    end

    def response(env)
      @app.call(env)
    end
  end

  Route = Struct.new(:http_verb, :path, :response)

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

      routes.find { |route| route.http_verb == http_verb && route.path == path }
    end
  end
end
