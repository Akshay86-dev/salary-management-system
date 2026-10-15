# frozen_string_literal: true

# Salary model for salary management system
# Tracks salary history with different types and effective dates
class Salary < ApplicationRecord
  # PaperTrail for versioning (track all salary changes)
  has_paper_trail

  # Associations
  belongs_to :employee, class_name: "User", foreign_key: :employee_id

  # Validations
  validates :amount, :currency, :effective_date, :salary_type, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :is_current, inclusion: { in: [ true, false ] }
  validates :currency, length: { is: 3 }, format: { with: /\A[A-Z]{3}\z/, message: "must be a valid ISO 4217 currency code" }
  before_save :clear_existing_current_salary, if: :is_current?

  enum :salary_type, {
    base: 0,
    bonus: 1,
    commission: 2,
    equity: 3
  }, validate: true

  # Scopes
  scope :active_salaries, -> { where(is_current: true) }
  scope :by_employee, ->(id) { where(employee_id: id) }
  scope :for_currency, ->(currency) { where(currency: currency) }
  scope :base_salaries, -> { where(salary_type: :base) }
  scope :ordered, -> { order(effective_date: :desc) }

  def amount_format
    "#{currency} #{amount}"
  end

  def current?
    is_current
  end

  # Set this salary as current, updating previous current salaries
  # Note: This should be called in a transaction to ensure consistency
  def set_as_current!
    transaction do
      employee.salaries.where(is_current: true, salary_type: salary_type).update_all(is_current: false)
      update!(is_current: true)
    end
  end

  # Find a salary for an employee (optionally by type)
  def self.find_current_for_employee(employee, type: nil)
    scope = by_employee(employee.id).active_salaries
    scope = scope.where(salary_type: type) if type
    scope.first
  end

  private

  def clear_existing_current_salary
    employee.salaries
            .where(is_current: true, salary_type: salary_type)
            .where.not(id: id)
            .update_all(is_current: false)
  end
end
