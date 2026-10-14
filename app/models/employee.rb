# frozen_string_literal: true

# Employee model for salary management system
# Represents an employee with personal info, job details, and salary history
class Employee < ApplicationRecord
  # Associations
  belongs_to :department
  belongs_to :location
  has_many :salaries, dependent: :destroy
  has_one :current_salary, -> { where(is_current: true) }, class_name: 'Salary'

  # Validations
  validates :first_name, :last_name, :email, :employee_id, :job_title, :hire_date, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :employee_id, uniqueness: true, format: { with: /\AEMP-\d{5}\z/, message: 'must be in format EMP-XXXXX' }
  validates :is_active, inclusion: { in: [true, false] }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :ordered, -> { order(:last_name, :first_name) }
  scope :search, ->(query) {
    where('lower(first_name) LIKE :q OR lower(last_name) LIKE :q OR lower(email) LIKE :q OR lower(employee_id) LIKE :q OR lower(job_title) LIKE :q',
          q: "%#{query.to_s.downcase}%")
  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def soft_delete
    update(is_active: false)
  end

  def active?
    is_active
  end

  def archived?
    !is_active
  end
end
