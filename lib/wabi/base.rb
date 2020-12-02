# frozen_string_literal: true

require './middleware/utils/cache'
require_relative 'parameters'

module Wabi
  class Base
    include Middleware::Utils::Cache

    NOT_FOUND_RESPONSE = [404, {}, [Rack::Utils::HTTP_STATUS_CODES[404]]].freeze
    DEFAULT_STATUS = 200
    DEFAULT_HEADERS = {}.freeze

    attr_reader :response, :router

    def initialize
      @router = Router.new
    end

    def routes(&block)
      router.instance_eval(&block)
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
      @route = router.find_route(@request.request_method, @request.path_info)
      return NOT_FOUND_RESPONSE unless @route

      @response = Rack::Response[*generate_response]
      @response.finish
    end

    def generate_response
      router.response(@route, self, request_env: @request.env)
    end
  end
end
