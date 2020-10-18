# frozen_string_literal: true

module Middleware
  class StaticDispatch
    DEFAULT_MIME_TYPE = 'text/plain'

    def initialize(_app, folder: 'public')
      @folder = folder
    end

    def call(env)
      request = Rack::Request.new(env)
      path = @folder + request.path

      if request.get?
        generate_response(path)
      else
        [400, {}, ['Bad request']]
      end
    end

    private

    def generate_response(path)
      if file_available?(path)
        [
          200,
          { 'Content-Type' => mime_type(path) },
          [File.read(path)]
        ]
      else
        [404, {}, ['Not found']]
      end
    end

    def file_available?(path)
      File.file?(path) && File.readable?(path)
    end

    def mime_type(path)
      Rack::Mime.mime_type(File.extname(path), DEFAULT_MIME_TYPE)
    end
  end
end
