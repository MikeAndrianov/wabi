# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

require './middleware/logger'
require './middleware/error_handler'
require './app'

use Middleware::Logger
use Middleware::ErrorHandler, show_trace: true
run App.new
