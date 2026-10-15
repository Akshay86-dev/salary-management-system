# frozen_string_literal: true

# Serializer for Employee model
# Produces JSON:API formatted responses
class EmployeeSerializer
  include JSONAPI::Serializer

  set_type :employee

  attributes :first_name, :last_name, :email, :employee_id, :job_title, :hire_date, :is_active

  attribute :full_name do |employee|
    employee.full_name
  end

  attribute :department_name do |employee|
    employee.department&.name
  end

  attribute :salary do |employee|
    employee.current_salary&.amount&.to_f
  end

  belongs_to :department
  belongs_to :location, optional: true
end
