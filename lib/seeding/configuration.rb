# frozen_string_literal: true

module Seeding
  module Configuration
    VALUES = {
      employee_count: 10_000,
      employee_batch_size: 1_000,
      salary_batch_size: 1_000,
      salary_range: { min: 45_000, max: 250_000 }
    }.freeze

    PROFILE_COUNTS = {
      small: 100,
      default: VALUES.fetch(:employee_count),
      large: 50_000
    }.freeze

    def self.for_profile(profile)
      name = case profile
      when String then profile.to_sym
      when Symbol then profile
      else
        raise ArgumentError, "Seed profile must be a string or symbol."
      end

      employee_count = PROFILE_COUNTS.fetch(name) do
        raise ArgumentError, "Unknown seed profile #{profile.inspect}. Available profiles: #{PROFILE_COUNTS.keys.join(', ')}."
      end

      VALUES.merge(employee_count: employee_count)
    end

    DEPARTMENT_NAMES = [
      "Engineering", "Sales", "Marketing", "Human Resources", "Finance",
      "Operations", "Customer Support", "Research & Development", "Legal",
      "Product Management", "Business Development", "Information Technology"
    ].freeze

    LOCATION_DATA = [
      { name: "New York Office", city: "New York", state: "NY", country: "USA" },
      { name: "San Francisco Office", city: "San Francisco", state: "CA", country: "USA" },
      { name: "Chicago Office", city: "Chicago", state: "IL", country: "USA" },
      { name: "Austin Office", city: "Austin", state: "TX", country: "USA" },
      { name: "Seattle Office", city: "Seattle", state: "WA", country: "USA" },
      { name: "Boston Office", city: "Boston", state: "MA", country: "USA" },
      { name: "Denver Office", city: "Denver", state: "CO", country: "USA" },
      { name: "Miami Office", city: "Miami", state: "FL", country: "USA" },
      { name: "Portland Office", city: "Portland", state: "OR", country: "USA" },
      { name: "Atlanta Office", city: "Atlanta", state: "GA", country: "USA" },
      { name: "Toronto Office", city: "Toronto", state: "ON", country: "Canada" },
      { name: "Vancouver Office", city: "Vancouver", state: "BC", country: "Canada" },
      { name: "Austin TX Satellite", city: "Austin", state: "TX", country: "USA" },
      { name: "Dallas Office", city: "Dallas", state: "TX", country: "USA" },
      { name: "Phoenix Office", city: "Phoenix", state: "AZ", country: "USA" },
      { name: "Philadelphia Office", city: "Philadelphia", state: "PA", country: "USA" },
      { name: "San Diego Office", city: "San Diego", state: "CA", country: "USA" },
      { name: "Detroit Office", city: "Detroit", state: "MI", country: "USA" }
    ].freeze

    JOB_TITLES = [
      "Software Engineer", "Senior Software Engineer", "Product Manager",
      "Sales Representative", "Account Manager", "Marketing Specialist",
      "HR Generalist", "HR Business Partner", "Financial Analyst",
      "Accountant", "Operations Manager", "Customer Support Specialist",
      "Technical Lead", "Team Lead", "Director of Engineering", "CTO",
      "VP of Sales", "Marketing Manager", "Finance Manager", "Legal Counsel"
    ].freeze

    SALARY_CURRENCIES = %w[USD USD USD USD CAD EUR].freeze
    BONUS_CURRENCIES = %w[USD USD CAD EUR].freeze
  end
end
