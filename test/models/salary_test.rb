require "test_helper"

class SalaryTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "creating a current salary replaces the current salary of the same type" do
    suffix = SecureRandom.hex(4)
    employee = User.create!(
      role: :employee,
      first_name: "Salary",
      last_name: "Test",
      email: "salary-#{suffix}@example.com",
      employee_id: "EMP-#{SecureRandom.random_number(100_000).to_s.rjust(5, '0')}",
      job_title: "Developer",
      hire_date: Date.current,
      department: Department.create!(name: "Salary Test #{suffix}"),
      location: Location.create!(name: "Salary Test #{suffix}", country: "USA")
    )

    previous_salary = employee.salaries.create!(
      amount: 50_000,
      currency: "USD",
      salary_type: :base,
      effective_date: Date.yesterday,
      is_current: true
    )

    new_salary = employee.salaries.create!(
      amount: 60_000,
      currency: "USD",
      salary_type: :base,
      effective_date: Date.current,
      is_current: true
    )

    assert_not previous_salary.reload.is_current
    assert_equal new_salary, employee.reload.current_salary
    assert_equal 60_000.0, EmployeeSerializer.new(employee).serializable_hash.dig(:data, :attributes, :salary)
    assert_equal employee.id, SalarySerializer.new(new_salary).serializable_hash.dig(:data, :attributes, :employee_id)
  end
end
