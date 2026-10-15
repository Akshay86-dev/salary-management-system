# frozen_string_literal: true

module ApiRequestHelpers
  def auth_headers(user = create_human_resource)
    token, = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    { "Authorization" => "Bearer #{token}", "Accept" => "application/json" }
  end

  def json_attributes(attributes)
    { data: { attributes: attributes } }
  end

  def create_human_resource
    User.create!(
      role: :human_resource,
      first_name: "Taylor",
      last_name: "HR",
      email: "hr-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!"
    )
  end

  def create_department(name: "Engineering")
    Department.create!(name: "#{name} #{SecureRandom.hex(3)}", budget: 500_000)
  end

  def create_location(name: "Head Office", state: "CA", country: "USA")
    Location.create!(name: "#{name} #{SecureRandom.hex(3)}", state:, country:)
  end

  def create_employee(department: create_department, location: create_location, **attributes)
    defaults = {
      role: :employee,
      first_name: "Alex",
      last_name: "Worker",
      email: "employee-#{SecureRandom.hex(4)}@example.com",
      job_title: "Developer",
      hire_date: Date.current,
      department:,
      location:
    }
    User.create!(defaults.merge(attributes))
  end

  def create_salary(employee:, amount: 60_000, currency: "USD", salary_type: :base, is_current: true)
    Salary.create!(
      employee:,
      amount:,
      currency:,
      salary_type: salary_type,
      effective_date: Date.current,
      is_current:
    )
  end
end
