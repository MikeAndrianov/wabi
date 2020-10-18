# frozen_string_literal: true

module Middleware
  class ErrorHandler
    def initialize(app, show_trace: false)
      @app = app
      @show_trace = show_trace
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      if @show_trace
        [500, {}, e.backtrace]
      else
        [500, {}, ['Something went wrong']]
      end
    end
  end
end
