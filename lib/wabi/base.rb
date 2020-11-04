# frozen_string_literal: true

require './middleware/utils/cache'
require_relative 'router'

module Wabi
  class Base
    include Middleware::Utils::Cache

    def self.get(path, &block)
      add_route('GET', path, block)
    end

    def self.post(path, &block)
      add_route('POST', path, block)
    end

    def call(env)
      http_verb = env['REQUEST_METHOD']
      path = env['PATH_INFO']

      resolve(http_verb, path)
    end

    private

    def resolve(http_verb, path)
      Router
        .instance
        .find_response(http_verb, path)
        .then { |response| instance_eval(&response) }
    end

    def self.add_route(http_verb, path, block)
      Router
        .instance
        .add_route(http_verb, path, block)
    end

    private_class_method :add_route
  end
end
