# frozen_string_literal: true

class App
  def call(env)
    status, = env

    if status == 500
      env
    else
      [200, {}, ['Hello world']]
    end
  end
end
