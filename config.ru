# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'logger'

Bundler.require

require './middleware/logger'
require './middleware/static_dispatch'
require './middleware/error_handler'
require './middleware/error_renderer'
require './middleware/etag'
require './app'

use Middleware::Logger, logger: Logger.new($stdout, level: Logger::INFO)
use Middleware::ErrorRenderer
use Middleware::StaticDispatch
use Middleware::ErrorHandler, show_trace: true
use Middleware::Etag
run App.new
