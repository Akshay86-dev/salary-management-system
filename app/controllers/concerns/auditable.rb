# frozen_string_literal: true

# Concern for auditing changes to models
# Automatically tracks create, update, and destroy actions
module Auditable
  extend ActiveSupport::Concern

  included do
    after_action :log_creation, only: [:create]
    after_action :log_update, only: [:update]
    after_action :log_deletion, only: [:destroy]
  end

  # Log creation events
  def log_creation
    return unless record.persisted?
    return if request.nil?

    audit = Audit.new
    audit.action = 'create'
    audit.track_attributes(record,
      user: current_user,
      ip_address: request.remote_ip,
      user_agent: request.user_agent)
    audit.save
  end

  # Log update events
  def log_update
    return unless record.persisted?
    return if request.nil?
    return if record.previous_changes.empty?

    audit = Audit.new
    audit.action = 'update'
    audit.track_attributes(record,
      user: current_user,
      ip_address: request.remote_ip,
      user_agent: request.user_agent)
    audit.save
  end

  # Log deletion events
  def log_deletion
    return if request.nil?
    return if record.nil?

    audit = Audit.new
    audit.action = 'destroy'
    audit.auditable_type = Audit::AUDITABLE_TYPES[record.class.name.downcase.to_sym] || record.class.name
    audit.auditable_id = record.id
    audit.previous_data = record.attributes.symbolize_keys.transform_keys(&:to_s)
    audit.new_data = {}
    audit.user = current_user
    audit.ip_address = request.remote_ip
    audit.user_agent = request.user_agent
    audit.save
  end

  # Helper method to get the current record
  def record
    @record
  end

  # Set the record being audited (called from controller actions)
  def audit_record(record)
    @record = record
  end
end