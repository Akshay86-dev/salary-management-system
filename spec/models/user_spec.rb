require "rails_helper"

RSpec.describe User, type: :model do
  describe "defaults and authentication" do
    it "defaults to employee and restricts authentication to human resources" do
      employee = described_class.new
      human_resource = described_class.new(role: :human_resource)

      expect(employee).to be_employee
      expect(employee).not_to be_active_for_authentication
      expect(human_resource).to be_human_resource
      expect(human_resource).to be_active_for_authentication
    end

    it "requires a password only for human resource users" do
      expect(described_class.new(role: :employee)).not_to be_password_required
      expect(described_class.new(role: :human_resource)).to be_password_required
    end
  end

  describe "validations and callbacks" do
    it "normalizes email before validation" do
      user = described_class.new(role: :human_resource, first_name: "Casey",
                                 last_name: "Example", email: "  CASEY@EXAMPLE.COM ")

      user.valid?

      expect(user.email).to eq("casey@example.com")
    end

    it "normalizes email when an existing user's email is changed" do
      user = create_employee
      user.email = "  UPDATED@EXAMPLE.COM "

      user.valid?

      expect(user.email).to eq("updated@example.com")
    end

    it "assigns a formatted employee ID to a new employee" do
      user = build_employee

      user.valid?

      expect(user.employee_id).to match(/\AEMP-\d{5}\z/)
    end

    it "assigns an employee ID before validating other employee fields" do
      user = build_employee
      user.job_title = nil

      expect(user).not_to be_valid
      expect(user.employee_id).to match(/\AEMP-\d{5}\z/)
      expect(user.errors[:job_title]).to be_present
    end

    it "generates the next employee ID after the highest existing ID" do
      existing = build_employee
      existing.employee_id = "EMP-00042"
      existing.save!
      next_employee = build_employee

      next_employee.valid?

      expect(next_employee.employee_id).to eq("EMP-00043")
    end

    it "preserves a supplied employee ID" do
      user = build_employee
      user.employee_id = "EMP-00123"

      user.valid?

      expect(user.employee_id).to eq("EMP-00123")
    end

    it "requires employee profile fields for employees" do
      user = described_class.new(role: :employee, first_name: "Alex", last_name: "Worker",
                                 email: "alex@example.com")

      expect(user).not_to be_valid
      expect(user.errors.attribute_names).to include(:job_title, :hire_date, :department_id, :location_id)
    end

    it "validates each employee profile field independently" do
      {
        job_title: nil,
        hire_date: nil,
        department: nil,
        location: nil
      }.each do |attribute, value|
        user = build_employee
        user.public_send("#{attribute}=", value)

        expect(user).not_to be_valid
        error_attribute = %i[department location].include?(attribute) ? :"#{attribute}_id" : attribute
        expect(user.errors[error_attribute]).to be_present
      end
    end

    it "rejects email addresses that differ only by case" do
      described_class.create!(role: :human_resource, first_name: "Casey", last_name: "Example",
                              email: "casey@example.com", password: "password123")
      duplicate = described_class.new(role: :human_resource, first_name: "Casey", last_name: "Example",
                                      email: "CASEY@EXAMPLE.COM", password: "password123")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "rejects email addresses with an invalid format" do
      user = described_class.new(role: :human_resource, first_name: "Casey",
                                 last_name: "Example", email: "not-an-email",
                                 password: "password123")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "rejects employee IDs with an invalid format or a duplicate value" do
      existing = create_employee
      invalid_format = build_employee
      invalid_format.employee_id = "EMP-1234"
      duplicate_id = build_employee
      duplicate_id.employee_id = existing.employee_id

      expect(invalid_format).not_to be_valid
      expect(invalid_format.errors[:employee_id]).to include("must be in format EMP-XXXXX")
      expect(duplicate_id).not_to be_valid
      expect(duplicate_id.errors[:employee_id]).to include("has already been taken")
    end

    it "reports when the employee ID range is exhausted" do
      highest_id = build_employee
      highest_id.employee_id = "EMP-99999"
      highest_id.save!
      next_employee = build_employee

      expect(next_employee).not_to be_valid
      expect(next_employee.errors[:employee_id]).to include("identifier range is exhausted")
    end

    it "does not require employee profile fields for human resource users" do
      user = described_class.new(role: :human_resource, first_name: "Taylor",
                                 last_name: "HR", email: "taylor@example.com",
                                 password: "password123")

      expect(user).to be_valid
      expect(user.employee_id).to be_nil
    end

    it "allows human resource users to be assigned a department and location without employee details" do
      department = Department.create!(name: "People")
      location = Location.create!(name: "Head Office", country: "USA")
      user = described_class.new(role: :human_resource, first_name: "Taylor",
                                 last_name: "HR", email: "taylor@example.com",
                                 password: "password123", department:, location:)

      expect(user).to be_valid
      expect(user.department).to eq(department)
      expect(user.location).to eq(location)
      expect(user.employee_id).to be_nil
    end

    it "does not regenerate an employee ID after the user has been created" do
      user = create_employee
      user.employee_id = nil

      expect(user).not_to be_valid
      expect(user.employee_id).to be_nil
      expect(user.errors[:employee_id]).to include("can't be blank")
    end

    it "rejects blank names and email addresses" do
      user = described_class.new(role: :human_resource, first_name: " ",
                                 last_name: nil, email: "  ")

      expect(user).not_to be_valid
      expect(user.errors.attribute_names).to include(:first_name, :last_name, :email)
    end

    it "rejects a missing employee ID when validating an existing employee" do
      employee = create_employee
      employee.employee_id = nil

      expect(employee).not_to be_valid
      expect(employee.errors[:employee_id]).to include("can't be blank")
    end

    it "requires is_active to be true or false" do
      user = build_employee
      user.is_active = nil

      expect(user).not_to be_valid
      expect(user.errors[:is_active]).to be_present
    end
  end

  describe "instance methods" do
    it "returns a full name and marks a user inactive when soft deleted" do
      user = create_employee

      expect(user.full_name).to eq("Alex Worker")
      expect(user.soft_delete).to be(true)
      expect(user.reload).to be_archived
      expect(user).not_to be_active
    end

    it "returns invalid authentication for employees" do
      expect(described_class.new(role: :employee).inactive_message).to eq(:invalid)
    end

    it "builds a full name without leading or trailing spaces when a name part is blank" do
      expect(described_class.new(first_name: "Alex", last_name: nil).full_name).to eq("Alex")
    end
  end

  describe "scopes" do
    it "filters and sorts employee records" do
      zed = create_employee(first_name: "Zed", last_name: "Zebra")
      amy = create_employee(first_name: "Amy", last_name: "Able")
      inactive = create_employee(first_name: "Ira", last_name: "Inactive", is_active: false)

      expect(described_class.employee_records).to contain_exactly(zed, amy, inactive)
      expect(described_class.active).to contain_exactly(zed, amy)
      expect(described_class.inactive).to contain_exactly(inactive)
      expect(described_class.ordered).to eq([ amy, inactive, zed ])
      expect(described_class.search("ABLE")).to contain_exactly(amy)
    end

    it "searches employee email, employee ID, and job title" do
      employee = create_employee(first_name: "Sam", last_name: "Search")
      employee.update!(job_title: "Platform Engineer")

      expect(described_class.search(employee.email)).to contain_exactly(employee)
      expect(described_class.search(employee.employee_id)).to contain_exactly(employee)
      expect(described_class.search("platform")).to contain_exactly(employee)
    end

    it "excludes human resource users from employee search results" do
      described_class.create!(role: :human_resource, first_name: "Taylor", last_name: "HR",
                              email: "platform-hr@example.com", password: "password123",
                              job_title: "Platform Engineer")

      expect(described_class.search("platform")).to be_empty
    end
  end

  describe "salary associations" do
    it "returns the current base salary but not a current bonus" do
      employee = create_employee
      base_salary = employee.salaries.create!(amount: 60_000, currency: "USD",
                                              salary_type: :base,
                                              effective_date: Date.current, is_current: true)
      employee.salaries.create!(amount: 5_000, currency: "USD",
                                salary_type: :bonus,
                                effective_date: Date.current, is_current: true)

      expect(employee.salaries.count).to eq(2)
      expect(employee.current_salary).to eq(base_salary)
    end

    it "destroys associated salaries when the employee is destroyed" do
      employee = create_employee
      salary = employee.salaries.create!(amount: 60_000, currency: "USD",
                                         salary_type: :base,
                                         effective_date: Date.current, is_current: true)

      employee.destroy!

      expect(Salary.exists?(salary.id)).to be(false)
    end
  end

  def build_employee(first_name: "Alex", last_name: "Worker")
    described_class.new(role: :employee, first_name:, last_name:,
                        email: "#{first_name.downcase}-#{SecureRandom.hex(4)}@example.com",
                        job_title: "Developer", hire_date: Date.current,
                        department: Department.create!(name: "Department #{SecureRandom.hex(4)}"),
                        location: Location.create!(name: "Location #{SecureRandom.hex(4)}", country: "USA"))
  end

  def create_employee(first_name: "Alex", last_name: "Worker", is_active: true)
    user = build_employee(first_name:, last_name:)
    user.is_active = is_active
    user.save!
    user
  end
end
