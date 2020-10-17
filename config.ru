# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

require './middleware/logger'
require './app'

use Middleware::Logger
run App.new
