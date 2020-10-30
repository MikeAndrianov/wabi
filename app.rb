# frozen_string_literal: true

require 'time'
require './middleware/utils/cache'

class App
  include Middleware::Utils::Cache

  def call(_env)
    fresh_when(
      [200, {}, ['Hello world!']],
      etag: 'custom etag',
      public: false,
      last_modified: (Time.new - 360).rfc2822
    )
  end
end
