# frozen_string_literal: true

module Wabi
  module Router
    class MountRoute
      attr_reader :path

      def initialize(path, mount_class)
        @path = path
        @mount_class = mount_class
        @app = @mount_class.new
      end

      def response(env)
        @app.call(env)
      end
    end
  end
end
