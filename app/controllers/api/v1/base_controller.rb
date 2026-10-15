# frozen_string_literal: true

# Base controller for API v1 endpoints
# All API v1 controllers should inherit from this controller
# Provides common response helpers and JWT authentication
class Api::V1::BaseController < ApplicationController
  # Authenticate users via JWT bearer token for all protected endpoints
  before_action :authenticate_user!
  before_action :require_human_resource!

  private

  def render_validation_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end

  # Render a standardized JSON error response
  # @param message [String] the error message
  # @param status [Symbol/Symbol] the HTTP status code
  def render_error(message, status: :bad_request)
    render json: { error: message }, status: status
  end

  # Render a standardized JSON success response
  # @param data [Hash/Array] the data to render
  # @param meta [Hash] optional metadata for pagination, etc.
  def render_success(data = {}, meta = {})
    response = { data: data }
    response[:meta] = meta unless meta.empty?
    render json: response, status: :ok
  end

  def render_collection(serializer, records)
    pagination = pagination_options
    return if pagination == :invalid

    unless pagination
      render json: serializer.new(records, is_collection: true)
      return
    end

    page, per_page = pagination
    total_count = records.count
    data = serializer.new(records.offset((page - 1) * per_page).limit(per_page), is_collection: true)
                     .serializable_hash

    render json: data.merge(
      meta: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    )
  end

  def require_human_resource!
    return if current_user&.human_resource?

    render json: { error: "Forbidden" }, status: :forbidden
  end

  def pagination_options
    return unless params.key?(:page) || params.key?(:per_page)

    page = params[:page].presence || "1"
    per_page = params[:per_page].presence || "50"
    unless page.to_s.match?(/\A[1-9]\d{0,8}\z/) &&
           per_page.to_s.match?(/\A[1-9]\d{0,2}\z/) &&
           per_page.to_i <= 100
      render_error("page must be a positive integer and per_page must be between 1 and 100",
                   status: :bad_request)
      return :invalid
    end

    [ page.to_i, per_page.to_i ]
  end
end
