# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'wabi_router'
  s.version = '0.0.1'
  s.summary = 'Router for Wabi framework'
  s.files = Dir['lib/**/*.rb', 'wabi_router.gemspec']
  s.require_paths = ['lib']
  s.authors = ['Mike Andrianov']
  s.required_ruby_version = '>= 2.7.0'
end
