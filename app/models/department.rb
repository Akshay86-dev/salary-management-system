# frozen_string_literal: true

# Department model for salary management system
# Each employee belongs to a department
class Department < ApplicationRecord
  # PaperTrail for versioning
  has_paper_trail

  # Associations
  has_many :employees, -> { where.not(employee_id: nil) }, class_name: "User",
                      dependent: :nullify
  belongs_to :manager, class_name: "User", optional: true, foreign_key: :manager_id

  # Note: budget calculation would go through salaries of active employees
  # has_many :salaries, through: :employees

  # Validations
  validates :name, presence: true, uniqueness: true

  # Scopes
  scope :ordered, -> { order(:name) }
end
