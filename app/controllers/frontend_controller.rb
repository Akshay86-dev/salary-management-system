# frozen_string_literal: true

class FrontendController < ApplicationController
  def index
    frontend_entry = Rails.root.join("public/vite/index.html")
    raise ActionController::RoutingError, "Not Found" unless frontend_entry.file?

    render file: frontend_entry, layout: false, content_type: "text/html"
  end
end
