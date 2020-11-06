# frozen_string_literal: true

class SecondApp
  def call(_env)
    [200, {}, ['Hello from SecondApp!']]
  end
end
