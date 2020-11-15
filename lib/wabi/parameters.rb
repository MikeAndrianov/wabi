# frozen_string_literal: true

module Wabi
  class Parameters
    def self.get(route, request)
      route
        .params_from_path(request.path_info)
        .merge(request.params.transform_keys(&:to_sym))
    end
  end
end
