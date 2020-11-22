# frozen_string_literal: true

module Wabi
  module Router
    module ParamsFromPath
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
end
