require "rails_helper"

RSpec.describe Salary, type: :model do
  let(:employee) { create_employee }

  describe "validations" do
    it "requires a positive amount, a valid currency, an effective date, and a salary type" do
      salary = described_class.new(employee:, amount: 0, currency: "usd",
                                   salary_type: nil, effective_date: nil)

      expect(salary).not_to be_valid
      expect(salary.errors.attribute_names).to include(:amount, :currency, :salary_type, :effective_date)
    end

    it "accepts a valid salary" do
      expect(build_salary).to be_valid
    end

    it "rejects negative amounts and currencies that are not uppercase three-letter codes" do
      negative_salary = build_salary(amount: -1)
      lower_case_currency = build_salary
      lower_case_currency.currency = "usd"
      long_currency = build_salary
      long_currency.currency = "USDD"

      expect(negative_salary).not_to be_valid
      expect(negative_salary.errors[:amount]).to be_present
      expect(lower_case_currency).not_to be_valid
      expect(long_currency).not_to be_valid
    end
  end

  describe "current salary behavior" do
    it "clears a previous current salary of the same type on save" do
      previous = create_salary(employee:, amount: 50_000, effective_date: Date.yesterday)

      current = create_salary(employee:, amount: 60_000, effective_date: Date.current)

      expect(previous.reload).not_to be_current
      expect(current).to be_current
    end

    it "keeps current salaries of different types independent" do
      base = create_salary(employee:, amount: 60_000)
      bonus = create_salary(employee:, amount: 5_000, salary_type: :bonus)

      expect(base.reload).to be_current
      expect(bonus.reload).to be_current
    end

    it "sets a salary as current and clears the other current salary of that type" do
      previous = create_salary(employee:, amount: 50_000)
      replacement = create_salary(employee:, amount: 60_000, is_current: false)

      replacement.set_as_current!

      expect(previous.reload).not_to be_current
      expect(replacement.reload).to be_current
    end

    it "finds the current salary by employee and optionally by type" do
      base = create_salary(employee:, amount: 60_000)
      create_salary(employee:, amount: 5_000, salary_type: :bonus)

      expect(described_class.find_current_for_employee(employee)).to eq(base)
      expect(described_class.find_current_for_employee(employee, type: :bonus))
        .to eq(employee.salaries.find_by!(salary_type: :bonus))
    end

    it "returns nil when the employee has no matching current salary" do
      expect(described_class.find_current_for_employee(employee)).to be_nil
      expect(described_class.find_current_for_employee(employee, type: :bonus)).to be_nil
    end
  end

  describe "salary type and formatting methods" do
    it "identifies salary types and formats the amount" do
      salary = build_salary

      expect(salary).to be_base
      expect(salary.salary_type).to eq("base")
      salary.save!
      expect(salary.reload.salary_type_before_type_cast).to eq(0)
      expect(salary.amount_format).to eq("USD #{salary.amount}")
      expect(salary.current?).to be(true)

      salary.salary_type = :bonus
      expect(salary).to be_bonus
      salary.salary_type = :commission
      expect(salary).to be_commission
      salary.salary_type = :equity
      expect(salary).to be_equity
    end

    it "exposes the enum mapping and rejects unsupported types" do
      expect(described_class.salary_types).to eq(
        "base" => 0,
        "bonus" => 1,
        "commission" => 2,
        "equity" => 3
      )

      invalid_salary = build_salary(salary_type: :other)
      expect(invalid_salary).not_to be_valid
      expect(invalid_salary.errors[:salary_type]).to be_present
    end
  end

  describe "scopes" do
    it "filters salary records and orders them by effective date descending" do
      recent = create_salary(employee:, amount: 70_000, effective_date: Date.current)
      older = create_salary(employee:, amount: 60_000, effective_date: Date.yesterday,
                            is_current: false)

      expect(described_class.active_salaries).to include(recent)
      expect(described_class.by_employee(employee.id)).to contain_exactly(recent, older)
      expect(described_class.for_currency("USD")).to include(recent, older)
      expect(described_class.base_salaries).to include(recent, older)
      expect(described_class.ordered.first).to eq(recent)
    end
  end

  def create_employee
    department = Department.create!(name: "Engineering")
    location = Location.create!(name: "Head Office", country: "USA")
    User.create!(role: :employee, first_name: "Alex", last_name: "Worker",
                 email: "employee-#{SecureRandom.hex(4)}@example.com",
                 job_title: "Developer", hire_date: Date.current, department:, location:)
  end

  def build_salary(employee: self.employee, amount: 60_000, salary_type: :base,
                   effective_date: Date.current, is_current: true)
    described_class.new(employee:, amount:, currency: "USD", salary_type:, effective_date:, is_current:)
  end

  def create_salary(employee:, amount:, salary_type: :base,
                    effective_date: Date.current, is_current: true)
    described_class.create!(employee:, amount:, currency: "USD", salary_type:,
                            effective_date:, is_current:)
  end
end
