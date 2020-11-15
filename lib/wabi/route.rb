# frozen_string_literal: true

module Wabi
  class Route
    attr_reader :http_verb, :path, :response

    def initialize(http_verb, path, response)
      @http_verb = http_verb
      @path = path
      @response = response
    end

    def params_from_path(request_path)
      request_path
        .match(named_capture_regex)
        .named_captures
    end

    private

    def named_capture_regex
      Regexp.new(path.gsub(/:(?<param>\w+)/, '(?<\k<param>>\w+)'))
    end
  end
end
