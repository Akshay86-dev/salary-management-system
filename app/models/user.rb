# frozen_string_literal: true

# User model for authentication and employee profile data
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :timeoutable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  enum :role, { employee: "EMPLOYEE", human_resource: "HUMAN_RESOURCE" }, default: :employee

  MAX_EMPLOYEE_ID_NUMBER = 99_999

  # Callbacks
  before_validation :normalize_email
  before_validation :generate_employee_id, on: :create, if: -> { employee? && employee_id.blank? }

  has_paper_trail ignore: %i[
    encrypted_password reset_password_token reset_password_sent_at
    remember_created_at sign_in_count current_sign_in_at last_sign_in_at
    current_sign_in_ip last_sign_in_ip
  ]

  # Associations
  belongs_to :department, optional: true
  belongs_to :location, optional: true
  has_many :salaries, foreign_key: :employee_id, dependent: :destroy
  has_one :current_salary,
          -> { where(is_current: true, salary_type: :base).order(effective_date: :desc, id: :desc) },
          class_name: "Salary",
          foreign_key: :employee_id

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :employee_id, presence: true, if: :employee?
  validates :employee_id, uniqueness: true, allow_nil: true,
                          format: { with: /\AEMP-\d{5}\z/, message: "must be in format EMP-XXXXX" }
  validates :job_title, :hire_date, :department_id, :location_id, presence: true, if: :employee?
  validates :is_active, inclusion: { in: [ true, false ] }

  # Scopes
  scope :ordered, -> { order(:last_name, :first_name) }
  scope :employee_records, -> { where.not(employee_id: nil) }
  scope :active, -> { employee_records.where(is_active: true) }
  scope :inactive, -> { employee_records.where(is_active: false) }
  scope :search, ->(query) {
    where.not(employee_id: nil).where(
      "lower(concat_ws(' ', first_name, last_name)) LIKE :q OR lower(first_name) LIKE :q OR lower(last_name) LIKE :q OR lower(email) LIKE :q OR lower(users.employee_id) LIKE :q OR lower(job_title) LIKE :q",
      q: "%#{query.to_s.downcase}%"
    )
  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
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

  def active_for_authentication?
    super && human_resource?
  end

  def password_required?
    human_resource? && super
  end

  def inactive_message
    human_resource? ? super : :invalid
  end

  private

  # Normalize email to be lowercase and trimmed
  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def generate_employee_id
    last_number = last_employee_id_number
    if last_number >= MAX_EMPLOYEE_ID_NUMBER
      errors.add(:employee_id, "identifier range is exhausted")
      return
    end

    self.employee_id = format("EMP-%05d", last_number + 1)
  end

  def last_employee_id_number
    self.class.employee_records
        .where("employee_id ~ '^EMP-[0-9]{5}$'")
        .maximum(Arel.sql("CAST(SUBSTRING(employee_id FROM 5) AS INTEGER)"))
        .to_i
  end
end
