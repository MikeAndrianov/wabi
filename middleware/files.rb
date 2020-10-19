# frozen_string_literal: true

module Middleware
  class Files
    attr_reader :body

    def initialize(file_path)
      @file_path = file_path
    end

    def find
      @body ||= File.read(@file_path) if available?
    end

    def mime_type
      @mime_type ||=
        Rack::Mime.mime_type(
          File.extname(@file_path),
          Rack::Mime.mime_type('.text')
        )
    end

    private

    def available?
      File.file?(@file_path) && File.readable?(@file_path)
    end
  end
end
