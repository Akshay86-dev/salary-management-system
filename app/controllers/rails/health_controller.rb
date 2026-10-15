# frozen_string_literal: true

module Rails
  class HealthController < ApplicationController
    def up
      render json: {
        status: "ok"
      }, status: :ok
    end
  end
end
