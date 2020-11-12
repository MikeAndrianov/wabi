# frozen_string_literal: true

require './middleware/utils/cache'
require_relative 'router'

module Wabi
  class Base
    include Middleware::Utils::Cache

    NOT_FOUND_RESPONSE = [404, {}, [Rack::Utils::HTTP_STATUS_CODES[404]]].freeze

    attr_reader :env

    def self.get(path, &block)
      add_route('GET', path, block)
    end

    def self.post(path, &block)
      add_route('POST', path, block)
    end

    def self.mount(path, app_class)
      Router
        .instance
        .add_mount_route(path, app_class)
    end

    def call(env)
      @env = env
      http_verb = env['REQUEST_METHOD']
      path = env['PATH_INFO']

      resolve(http_verb, path, env)
    end

    private

    def resolve(http_verb, path, env)
      route = Router.instance.find_route(http_verb, path)
      return NOT_FOUND_RESPONSE unless route

      if route.is_a?(Wabi::MountRoute)
        route.response(env)
      else
        instance_eval(&route.response)
      end
    end

    def self.add_route(http_verb, path, block)
      Router
        .instance
        .add_route(http_verb, path, block)
    end

    private_class_method :add_route
  end
end
