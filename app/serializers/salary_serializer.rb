# frozen_string_literal: true

# Serializer for Salary model
# Produces JSON:API formatted responses
class SalarySerializer
  include JSONAPI::Serializer

  attributes :employee_id, :amount, :currency, :salary_type, :effective_date, :is_current

  attribute :formatted_amount do |salary|
    salary.amount_format
  end

  belongs_to :employee
end
