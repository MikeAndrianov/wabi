# frozen_string_literal: true

require_relative 'support/refined_hash'

module Wabi
  class Route
    attr_reader :http_verb, :path, :response

    using RefinedHash

    def initialize(http_verb, path, response)
      @http_verb = http_verb
      @path = path
      @response = response
    end

    def match?(request_http_verb, request_path)
      return false unless http_verb == request_http_verb

      if path.include?(':')
        regex = Regexp.new(path.gsub(/:\w+/, '\w+'))

        request_path.match?(regex)
      else
        path == request_path
      end
    end

    def params_for_request(request)
      params_from_path(request.path_info)
        .merge(request.params)
        .deep_symbolize_keys
    end

    private

    def params_from_path(request_path)
      request_path
        .match(named_capture_regex)
        .named_captures
    end

    def named_capture_regex
      Regexp.new(path.gsub(/:(?<param>\w+)/, '(?<\k<param>>\w+)'))
    end
  end
end
