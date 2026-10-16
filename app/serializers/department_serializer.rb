# frozen_string_literal: true

# Serializer for Department model
# Produces JSON:API formatted responses
class DepartmentSerializer
  include JSONAPI::Serializer

  attributes :name, :budget

  attribute :manager_id do |department|
    department.manager_id if department.manager_id
  end
end
