# frozen_string_literal: true

class App
  def call(_env)
    [200, {}, ['Hello world!']]
  end
end
