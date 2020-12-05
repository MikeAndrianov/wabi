# frozen_string_literal: true

require 'json'

module Wabi
  module RefinedHash
    refine Hash do
      def deep_symbolize_keys
        JSON.parse(JSON[self], symbolize_names: true)
      end
    end
  end
end
