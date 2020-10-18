# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'logger'

Bundler.require

require './middleware/logger'
require './middleware/error_handler'
require './app'

use Middleware::Logger, logger: Logger.new($stdout, level: Logger::INFO)
use Middleware::ErrorHandler, show_trace: false
run App.new
