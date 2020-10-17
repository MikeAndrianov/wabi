# frozen_string_literal: true

require 'json'
require 'logger'
require 'benchmark'

module Middleware
  class Logger
    FILTERED_PARAMS = %w[password password_confirmation].freeze

    def initialize(app, logger: nil, filtered_params: FILTERED_PARAMS)
      @app = app
      @logger = logger || ::Logger.new($stdout, level: ::Logger::INFO)
      @filtered_params = filtered_params
    end

    def call(env)
      request = Rack::Request.new(env)
      response = nil

      response_time = Benchmark.measure do
        response = @app.call(env)
      end
      log_request(request, response_time.real)

      response
    end

    private

    def log_request(request, response_time_in_seconds)
      response_time_in_seconds
        .then { |time_sec| time_sec * 1_000 }
        .then { |time_ms| log_record(request, time_ms) }
        .then { |record| @logger.info(record) }
    end

    def log_record(request, response_time_in_ms)
      "#{DateTime.now}: #{request.request_method} #{request.path}"\
      "\nparams: #{params(request)}\n"\
      "Response Time: #{response_time_in_ms} ms"
    end

    def params(request)
      query_params(request)
        .merge(body_params(request))
    end

    def query_params(request)
      request
        .query_string
        .split('&')
        .each_with_object({}) do |key_value_pair, res|
          key, value = key_value_pair.split('=')
          res[key] = filtered_value(key, value)
        end
    end

    # FUY: handles only JSON format for now
    def body_params(request)
      body = request.body.read
      return {} if body.empty?

      JSON
        .parse(body)
        .each_with_object({}) { |(key, value), res| res[key] = filtered_value(key, value) }
    end

    def filtered_value(key, value)
      @filtered_params.include?(key) ? '[FILTERED]' : value
    end
  end
end
