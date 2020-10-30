# frozen_string_literal: true

module Middleware
  module Utils
    module Cache
      def fresh_when(result, options)
        return result if options.empty?

        result.tap do |_, headers, _|
          headers
            .merge!(
              Rack::ETAG => options[:last_modified],
              Rack::CACHE_CONTROL => options[:cache_control],
              'Last-Modified' => options[:last_modified]
            ).compact!
        end
      end
    end
  end
end
