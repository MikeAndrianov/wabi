# frozen_string_literal: true

require 'time'
require './middleware/utils/cache'

class App
  include Middleware::Utils::Cache

  def call(_env)
    fresh_when(
      [200, {}, ['Hello world!']],
      etag: [1, 'test', { key: :value }],
      cache_control: 'max-age=18000, private',
      last_modified: (Time.new - 360).rfc2822
    )
  end
end
