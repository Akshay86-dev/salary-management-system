# frozen_string_literal: true

# Department model for salary management system
# Each employee belongs to a department
class Department < ApplicationRecord
  # PaperTrail for versioning
  has_paper_trail

  # Associations
  has_many :employees, dependent: :nullify
  belongs_to :manager, class_name: 'Department', optional: true

  # Note: budget calculation would go through salaries of active employees
  # has_many :salaries, through: :employees

  # Validations
  validates :name, presence: true, uniqueness: true

  # Scopes
  scope :ordered, -> { order(:name) }
end