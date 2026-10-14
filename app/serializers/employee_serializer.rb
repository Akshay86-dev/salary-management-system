# frozen_string_literal: true

# Serializer for Employee model
# Produces JSON:API formatted responses
class EmployeeSerializer
  include JSONAPI::Serializer

  attributes :first_name, :last_name, :email, :employee_id, :job_title, :hire_date, :is_active

  attribute :full_name do |employee|
    employee.full_name
  end

  belongs_to :department
  belongs_to :location, optional: true
end
