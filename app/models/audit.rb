# frozen_string_literal: true

# Audit model for change tracking
# Records all changes to salary-related data for compliance and debugging
class Audit < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Action types as constants
  ACTIONS = {
    create: 0,
    update: 1,
    destroy: 2
  }.freeze

  # Auditable types mapping
  AUDITABLE_TYPES = {
    employee: 0,
    salary: 1,
    department: 2
  }.freeze

  # Serialize JSON fields for easy access
  serialize :previous_data, coder: JSON
  serialize :new_data, coder: JSON

  # Validations
  validates :action, presence: true, inclusion: { in: ACTIONS.values }
  validates :auditable_type, presence: true, inclusion: { in: AUDITABLE_TYPES.values }
  validates :auditable_id, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :for_employee, ->(id) { where(auditable_type: AUDITABLE_TYPES[:employee], auditable_id: id) }
  scope :for_salary, ->(id) { where(auditable_type: AUDITABLE_TYPES[:salary], auditable_id: id) }
  scope :for_department, ->(id) { where(auditable_type: AUDITABLE_TYPES[:department], auditable_id: id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :create_actions, -> { where(action: ACTIONS[:create]) }
  scope :update_actions, -> { where(action: ACTIONS[:update]) }
  scope :destroy_actions, -> { where(action: ACTIONS[:destroy]) }

  # Instance methods
  def change_summary
    keys = (previous_data.keys | new_data.keys).sort
    changes = {}

    keys.each do |key|
      old_val = previous_data[key] || '[none]'
      new_val = new_data[key] || '[none]'
      changes[key] = { from: old_val, to: new_val } if old_val != new_val
    end

    changes
  end

  def auditable_model
    case auditable_type
    when AUDITABLE_TYPES[:employee]
      Employee.find_by(id: auditable_id)
    when AUDITABLE_TYPES[:salary]
      Salary.find_by(id: auditable_id)
    when AUDITABLE_TYPES[:department]
      Department.find_by(id: auditable_id)
    end
  end

  def track_attributes(record, user: nil, ip_address: nil, user_agent: nil)
    self.user = user
    self.auditable_type = AUDITABLE_TYPES[record.class.name.downcase.to_sym] || record.class.name
    self.auditable_id = record.id
    self.previous_data = record.previous_changes.transform_values { |v| v.is_a?(Array) ? v.first : v }
    self.new_data = record.changes.transform_values { |v| v.is_a?(Array) ? v.last : v }
    self.ip_address = ip_address
    self.user_agent = user_agent
  end
end
