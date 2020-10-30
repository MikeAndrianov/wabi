# frozen_string_literal: true

module Middleware
  module Utils
    module Cache
      def fresh_when(result, options)
        return result if options.empty?

        result.tap do |response|
          response[1].merge!(fresh_when_options: options)
        end
      end
    end
  end
end
