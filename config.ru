# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

require './middleware/logger'
require './app'

app =
  Rack::Builder.new do |builder|
    builder.use(Middleware::Logger)
    builder.run(App.new)
  end

run app
