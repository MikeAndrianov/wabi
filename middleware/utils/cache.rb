# frozen_string_literal: true

require 'digest'

module Middleware
  module Utils
    module Cache
      def fresh_when(response_body, options)
        return response_body if options.empty?

        response_body.tap do |_body|
          headers(
            Rack::ETAG => generate_etag(options[:etag]),
            Rack::CACHE_CONTROL => options[:cache_control],
            'Last-Modified' => options[:last_modified]
          ).compact!
        end
      end

      private

      def generate_etag(obj)
        Digest::SHA256.hexdigest(obj.to_s)
      end
    end
  end
end
