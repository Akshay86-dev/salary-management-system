require "rails_helper"

RSpec.describe Location, type: :model do
  describe "validations" do
    it "requires a name and a supported country" do
      expect(Location.new(country: "USA")).not_to be_valid
      expect(Location.new(name: "Office", country: "Atlantis")).not_to be_valid
    end

    it "accepts supported countries" do
      expect(Location.new(name: "Office", country: "USA")).to be_valid
      expect(Location.new(name: "Office", country: "Canada")).to be_valid
      expect(Location.new(name: "Office", country: "Mexico")).to be_valid
      expect(Location.new(name: "Office", country: "UK")).to be_valid
    end

    it "requires a country" do
      expect(Location.new(name: "Office", country: nil)).not_to be_valid
    end
  end

  describe "address methods" do
    it "formats an address from the available address components" do
      location = Location.new(name: "Main Office", address: "10 Main St", city: "Toronto",
                              state: "ON", zip_code: "M5V 2T6")

      expect(location.full_address).to eq("10 Main St, Toronto, ON, M5V 2T6")
      expect(location.formatted_location).to eq("Main Office, Toronto, ON M5V 2T6")
    end

    it "uses the location name when no address components are present" do
      expect(Location.new(name: "Remote").full_address).to eq("Remote")
    end
  end

  describe "scopes" do
    it "filters by state and searches location fields case-insensitively" do
      toronto = Location.create!(name: "Toronto Office", city: "Toronto", state: "ON", country: "Canada")
      Location.create!(name: "London Office", city: "London", state: "UK", country: "UK")

      expect(Location.by_state("ON")).to contain_exactly(toronto)
      expect(Location.search("TORONTO")).to contain_exactly(toronto)
    end

    it "searches by city and state and returns no results for an unmatched query" do
      office = Location.create!(name: "Downtown", city: "Toronto", state: "ON", country: "Canada")

      expect(Location.search("on")).to include(office)
      expect(Location.search("missing")).to be_empty
    end

    it "orders locations by name" do
      second = Location.create!(name: "West Office", country: "USA")
      first = Location.create!(name: "East Office", country: "USA")

      expect(Location.ordered).to eq([ first, second ])
    end

    it "returns employees assigned to the location" do
      location = Location.create!(name: "Head Office", country: "USA")
      department = Department.create!(name: "Engineering")
      employee = User.create!(role: :employee, first_name: "Alex", last_name: "Worker",
                              email: "alex@example.com", employee_id: "EMP-00001",
                              job_title: "Developer", hire_date: Date.current,
                              department:, location:)
      User.create!(role: :human_resource, first_name: "Taylor", last_name: "HR",
                   email: "hr@example.com", password: "password123")

      expect(location.employees).to contain_exactly(employee)
    end
  end
end
