# frozen_string_literal: true

require './middleware/utils/cache'
require_relative 'router'
require_relative 'parameters'

module Wabi
  class Base
    include Middleware::Utils::Cache

    NOT_FOUND_RESPONSE = [404, {}, [Rack::Utils::HTTP_STATUS_CODES[404]]].freeze
    DEFAULT_STATUS = 200
    DEFAULT_HEADERS = {}.freeze

    attr_reader :response

    def self.get(path, &block)
      add_route('GET', path, block)
    end

    def self.post(path, &block)
      add_route('POST', path, block)
    end

    def self.resources(resource_plural_name, except: [])
      Router
        .instance
        .add_resources_route(resource_plural_name, except)
    end

    def self.mount(path, app_class)
      Router
        .instance
        .add_mount_route(path, app_class)
    end

    def call(env)
      @request = Rack::Request.new(env)

      resolve
    end

    def params
      @params ||= Parameters.get(@route, @request)
    end

    # rubocop:disable Style/TrivialAccessors
    def headers(header_hash)
      @headers = header_hash
    end

    def status(status)
      @status = status
    end
    # rubocop:enable Style/TrivialAccessors

    private

    def resolve
      @route = Router.instance.find_route(@request.request_method, @request.path_info)
      return NOT_FOUND_RESPONSE unless @route

      @response = Rack::Response[*generate_response]
      @response.finish
    end

    def generate_response
      case @route
      when Wabi::MountRoute, Wabi::ResourcesRoute
        @route.response(@request.env)
      else
        route_response
      end
    end

    def route_response
      body = instance_eval(&@route.response)

      [
        @status || DEFAULT_STATUS,
        @headers || DEFAULT_HEADERS,
        [body]
      ]
    end

    def self.add_route(http_verb, path, block)
      Router
        .instance
        .add_route(http_verb, path, block)
    end

    private_class_method :add_route
  end
end
