# This file should ensure the existence of records required to run the application.
# The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

# Configuration constants
SEED_CONFIG = {
  department_count: 12,
  location_count: 18,
  employee_count: 10_000,
  salary_range: { min: 45000, max: 250000 }
}.freeze

# Department names for the salary management system
DEPARTMENT_NAMES = [
  'Engineering', 'Sales', 'Marketing', 'Human Resources', 'Finance',
  'Operations', 'Customer Support', 'Research & Development', 'Legal',
  'Product Management', 'Business Development', 'Information Technology'
].freeze

# Location data (city, state pairs)
LOCATION_DATA = [
  { name: 'New York Office', city: 'New York', state: 'NY', country: 'USA' },
  { name: 'San Francisco Office', city: 'San Francisco', state: 'CA', country: 'USA' },
  { name: 'Chicago Office', city: 'Chicago', state: 'IL', country: 'USA' },
  { name: 'Austin Office', city: 'Austin', state: 'TX', country: 'USA' },
  { name: 'Seattle Office', city: 'Seattle', state: 'WA', country: 'USA' },
  { name: 'Boston Office', city: 'Boston', state: 'MA', country: 'USA' },
  { name: 'Denver Office', city: 'Denver', state: 'CO', country: 'USA' },
  { name: 'Miami Office', city: 'Miami', state: 'FL', country: 'USA' },
  { name: 'Portland Office', city: 'Portland', state: 'OR', country: 'USA' },
  { name: 'Atlanta Office', city: 'Atlanta', state: 'GA', country: 'USA' },
  { name: 'Toronto Office', city: 'Toronto', state: 'ON', country: 'Canada' },
  { name: 'Vancouver Office', city: 'Vancouver', state: 'BC', country: 'Canada' },
  { name: 'Austin TX Satellite', city: 'Austin', state: 'TX', country: 'USA' },
  { name: 'Dallas Office', city: 'Dallas', state: 'TX', country: 'USA' },
  { name: 'Phoenix Office', city: 'Phoenix', state: 'AZ', country: 'USA' },
  { name: 'Philadelphia Office', city: 'Philadelphia', state: 'PA', country: 'USA' },
  { name: 'San Diego Office', city: 'San Diego', state: 'CA', country: 'USA' },
  { name: 'Detroit Office', city: 'Detroit', state: 'MI', country: 'USA' }
].freeze

# Job titles for employees
JOB_TITLES = [
  'Software Engineer', 'Senior Software Engineer', 'Product Manager',
  'Sales Representative', 'Account Manager', 'Marketing Specialist',
  'HR Generalist', 'HR Business Partner', 'Financial Analyst',
  'Accountant', 'Operations Manager', 'Customer Support Specialist',
  'Technical Lead', 'Team Lead', 'Director of Engineering', 'CTO',
  'VP of Sales', 'Marketing Manager', 'Finance Manager', 'Legal Counsel'
].freeze

# Salary types enum values
SALARY_TYPES = {
  base: 0,
  bonus: 1,
  commission: 2,
  equity: 3
}.freeze

# Helper methods

# Generate employee ID in format EMP-XXXXX
def generate_employee_id(index)
  "EMP-#{index.to_s.rjust(5, '0')}"
end

# Generate random salary amount within configured range
def random_salary_amount
  rand(SEED_CONFIG[:salary_range][:min]..SEED_CONFIG[:salary_range][:max]).to_f.round(2)
end

# Generate random percentage of base salary for bonuses/commissions
def random_percentage(amount)
  (amount * rand(0.05..0.25)).round(2)
end

puts "Starting database seeding..."
puts "Target counts: #{SEED_CONFIG[:employee_count]} employees"
puts "=" * 60

# Seed Departments
puts "\n1/5: Seeding #{DEPARTMENT_NAMES.length} departments..."

departments = []
DEPARTMENT_NAMES.each do |name|
  department = Department.find_or_create_by!(name: name) do |dept|
    dept.budget = rand(500_000..5_000_000).to_f.round(2)
  end
  departments << department
  puts "  ✓ Created department: #{name}"
end
puts "Departments seeded: #{departments.length} records"

# Seed Locations
puts "\n2/5: Seeding #{LOCATION_DATA.length} locations..."

locations = []
LOCATION_DATA.each_with_index do |loc_data, index|
  location = Location.find_or_create_by!(name: loc_data[:name]) do |loc|
    loc.city = loc_data[:city]
    loc.state = loc_data[:state]
    loc.zip_code = Faker::Address.zip_code
    loc.country = loc_data[:country]
    loc.address = Faker::Address.street_address
    loc.latitude = Faker::Address.latitude
    loc.longitude = Faker::Address.longitude
  end
  locations << location
  puts "  ✓ Created location: #{location.name}" if index < 5
end
puts "Locations seeded: #{locations.length} records"

# Seed Admin User
puts "\n3/5: Seeding admin user..."
if User.count == 0
  admin = User.create!(
    email: 'admin@salarymgmt.com',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Admin',
    last_name: 'User'
  )
  puts "  ✓ Created admin user: #{admin.email}"
else
  puts "  Users already exist (#{User.count} records)"
end

# Seed Employees
puts "\n4/5: Seeding #{SEED_CONFIG[:employee_count]} employees..."

# Clear existing employees for idempotency
if Employee.count > 0
  puts "  Clearing existing employees..."
  Salary.delete_all
  Employee.delete_all
end

# Pre-generate random names for performance
first_names = Array.new(SEED_CONFIG[:employee_count]) { Faker::Name.first_name }
last_names = Array.new(SEED_CONFIG[:employee_count]) { Faker::Name.last_name }

created_count = 0
batch_size = 1000

(0...SEED_CONFIG[:employee_count]).step(batch_size) do |start_idx|
  end_idx = [start_idx + batch_size - 1, SEED_CONFIG[:employee_count] - 1].min
  employees_to_create = []

  (start_idx..end_idx).each do |i|
    first_name = first_names[i]
    last_name = last_names[i]
    employee_id = generate_employee_id(i + 1)

    employees_to_create << {
      first_name: first_name,
      last_name: last_name,
      email: Faker::Internet.email(name: "#{first_name} #{last_name}"),
      employee_id: employee_id,
      job_title: JOB_TITLES.sample,
      hire_date: Faker::Date.between(from: 5.years.ago, to: Date.current),
      department_id: departments.sample.id,
      location_id: locations.sample.id,
      is_active: [true, true, true, false].sample,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  Employee.insert_all!(employees_to_create)
  created_count += employees_to_create.length
  puts "  Progress: #{created_count}/#{SEED_CONFIG[:employee_count]} employees created..."
end

puts "Employees seeded: #{Employee.count} records"

# Seed Salaries
puts "\n5/5: Seeding salaries for all employees..."

salaries_to_create = []
batch_count = 0

Employee.find_each(batch_size: 1000) do |employee|
  base_amount = random_salary_amount
  currency = ['USD', 'USD', 'USD', 'USD', 'CAD', 'EUR'].sample

  # Base salary (current)
  salaries_to_create << {
    employee_id: employee.id,
    amount: base_amount,
    currency: currency,
    salary_type: SALARY_TYPES[:base],
    effective_date: employee.hire_date,
    is_current: true,
    created_at: Time.current,
    updated_at: Time.current
  }

  # Bonus (15% chance)
  if rand < 0.15
    salaries_to_create << {
      employee_id: employee.id,
      amount: random_percentage(base_amount),
      currency: ['USD', 'USD', 'CAD', 'EUR'].sample,
      salary_type: SALARY_TYPES[:bonus],
      effective_date: employee.hire_date + rand(1..12).months,
      is_current: true,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  # Commission (8% chance, some historical)
  if rand < 0.08
    salaries_to_create << {
      employee_id: employee.id,
      amount: random_percentage(base_amount),
      currency: currency,
      salary_type: SALARY_TYPES[:commission],
      effective_date: employee.hire_date + rand(0..6).months,
      is_current: [true, false].sample,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  # Equity (5% chance)
  if rand < 0.05
    salaries_to_create << {
      employee_id: employee.id,
      amount: (base_amount * rand(1..5)),
      currency: 'USD',
      salary_type: SALARY_TYPES[:equity],
      effective_date: employee.hire_date + rand(6..24).months,
      is_current: true,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  # Batch insert every 1000 salary records
  if salaries_to_create.length >= 1000
    Salary.insert_all!(salaries_to_create)
    batch_count += 1
    puts "  Progress: #{Salary.count} salary records created..."
    salaries_to_create = []
  end
end

# Insert remaining salaries
unless salaries_to_create.empty?
  Salary.insert_all!(salaries_to_create)
end

puts "Salaries seeded: #{Salary.count} records"

# Assign department managers
puts "\nAssigning department managers..."
departments.each do |dept|
  manager = Employee.where(department_id: dept.id, is_active: true).order('RANDOM()').first
  if manager
    dept.update!(manager_id: manager.id)
    puts "  ✓ #{dept.name} → #{manager.full_name}"
  end
end

# Final Summary
puts "\n" + "=" * 60
puts "DATABASE SEEDING COMPLETE!"
puts "=" * 60
puts "Departments: #{Department.count}"
puts "Locations: #{Location.count}"
puts "Employees: #{Employee.count}"
puts "Active Employees: #{Employee.active.count}"
puts "Inactive Employees: #{Employee.inactive.count}"
puts "Salaries: #{Salary.count}"
puts "Current Salaries: #{Salary.active_salaries.count}"
puts "Users: #{User.count}"
puts "=" * 60
