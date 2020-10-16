# frozen_string_literal: true

require 'json'
require 'fileutils'

module Middleware
  class Logger
    FILTERED_PARAMS = %w[password password_confirmation].freeze
    LOGS_FOLDER = 'logs'

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      log_request(request)

      @app.call(env)
    end

    private

    def log_request(request)
      FileUtils.mkdir_p(LOGS_FOLDER) unless File.directory?(LOGS_FOLDER)

      file = File.open("#{LOGS_FOLDER}/#{file_name}", 'a')
      file.write(log_record(request))
      file.close
    end

    def log_record(request)
      "#{DateTime.now}: #{request.request_method} #{request.path}\nparams: #{params(request)}\n\n"
    end

    def file_name
      "#{environment}.log"
    end

    def environment
      :production
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
      FILTERED_PARAMS.include?(key) ? '[FILTERED]' : value
    end
  end
end
