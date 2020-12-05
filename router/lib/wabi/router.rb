# frozen_string_literal: true

require_relative 'route'
require_relative 'mount_route'
require_relative 'resources_route'

module Wabi
  class Router
    attr_accessor :routes, :mount_routes, :resources_routes

    def initialize
      @routes = []
      @mount_routes = []
    end

    def get(path, &block)
      add_route('GET', path, block)
    end

    def post(path, &block)
      add_route('POST', path, block)
    end

    def resources(resource_plural_name, except: [])
      @routes << ResourcesRoute.new(resource_plural_name, except)
    end

    def mount(path, app_class)
      @mount_routes << MountRoute.new(path, app_class)
    end

    def find_route(http_verb, path)
      mount_route = @mount_routes.find { |route| path.start_with?(route.path) }
      return mount_route if mount_route

      routes.find { |route| route.match?(http_verb, path) }
    end

    def response(route, app, request_env:)
      case route
      when Wabi::MountRoute, Wabi::ResourcesRoute
        route.response(request_env)
      else
        route_response(route, app)
      end
    end

    private

    def add_route(http_verb, path, response)
      @routes << Route.new(http_verb, path, response)
    end

    def route_response(route, app)
      # TODO: maybe it's not a best idea to use here app instance
      body = app.instance_eval(&route.response)

      # TODO: get rid of this hack
      headers = app.instance_eval { @headers } || Wabi::Base::DEFAULT_HEADERS
      status = app.instance_eval { @status } || Wabi::Base::DEFAULT_STATUS

      [status, headers, [body]]
    end
  end
end
