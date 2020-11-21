# frozen_string_literal: true

require_relative 'params_from_path'

module Wabi
  class Route
    include ParamsFromPath

    attr_reader :http_verb, :path, :response

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
  end
end
