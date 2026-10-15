require "rails_helper"

RSpec.describe Department, type: :model do
  describe "validations" do
    it "requires a name" do
      expect(Department.new(name: nil)).not_to be_valid
    end

    it "requires unique names" do
      Department.create!(name: "Engineering")

      expect(Department.new(name: "Engineering")).not_to be_valid
    end
  end

  describe "associations" do
    it "allows a department without a manager" do
      department = Department.create!(name: "Engineering")

      expect(department.manager).to be_nil
    end

    it "has employees with an employee ID and an optional manager" do
      department = Department.create!(name: "Engineering")
      manager = User.create!(role: :human_resource, first_name: "Morgan", last_name: "Manager",
                             email: "manager@example.com", password: "password123")
      employee = create_employee(department:)
      hr_user = User.create!(role: :human_resource, first_name: "Taylor", last_name: "HR",
                             email: "hr@example.com", password: "password123")

      department.update!(manager:)

      expect(department.manager).to eq(manager)
      expect(department.employees).to contain_exactly(employee)
      expect(department.employees).not_to include(hr_user)
    end
  end

  describe ".ordered" do
    it "orders departments by name" do
      second = Department.create!(name: "Zoology")
      first = Department.create!(name: "Accounting")

      expect(Department.ordered).to eq([ first, second ])
    end
  end

  def create_employee(department:)
    location = Location.create!(name: "Head Office", country: "USA")
    User.create!(role: :employee, first_name: "Alex", last_name: "Worker",
                 email: "employee@example.com", employee_id: "EMP-00001",
                 job_title: "Developer", hire_date: Date.current,
                 department:, location:)
  end
end
