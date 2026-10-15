# frozen_string_literal: true

module Seeding
  class LocationCommand
    def call
      puts "\n2/6: Seeding #{Configuration::LOCATION_DATA.length} locations..."

      locations = Configuration::LOCATION_DATA.each_with_index.map do |attributes, index|
        location = Location.find_or_create_by!(name: attributes[:name]) do |record|
          record.assign_attributes(attributes)
          record.zip_code = Faker::Address.zip_code
          record.address = Faker::Address.street_address
          record.latitude = Faker::Address.latitude
          record.longitude = Faker::Address.longitude
        end
        puts "  Created location: #{location.name}" if index < 5
        location
      end

      puts "Locations seeded: #{locations.length} records"
      locations
    end
  end
end
