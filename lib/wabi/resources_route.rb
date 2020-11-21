# frozen_string_literal: true

module Wabi
  class ResourcesRoute
    Action = Struct.new(:name, :http_verb, :path)

    attr_reader :actions

    def initialize(resource_plural_name, except = [])
      @resource_plural_name = resource_plural_name
      @except = except
      @actions = default_actions.delete_if { |action| except.include?(action.name) }
    end

    def response(_env)
      [200, {}, []]
    end

    def match?(request_http_verb, request_path)
      !!find_action(request_http_verb, request_path)
    end

    private

    def find_action(request_http_verb, request_path)
      actions.find do |action|
        if action.path.include?(':')
          next unless action.http_verb == request_http_verb

          regex = Regexp.new(action.path.gsub(/:\w+/, '\w+'))
          request_path.match?(regex)
        else
          action.path == request_path
        end
      end
    end

    def default_actions
      [
        Action.new(:index, Rack::GET, prefix),
        Action.new(:show, Rack::GET, "#{prefix}/:id"),
        Action.new(:new, Rack::GET, "#{prefix}/new"),
        Action.new(:edit, Rack::GET, "#{prefix}/:id/edit"),
        Action.new(:create, Rack::POST, prefix),
        Action.new(:update, Rack::PUT, "#{prefix}/:id"),
        Action.new(:update, Rack::PATCH, "#{prefix}/:id"),
        Action.new(:destroy, Rack::DELETE, "#{prefix}/:id")
      ]
    end

    def prefix
      "/#{@resource_plural_name}"
    end
  end
end
