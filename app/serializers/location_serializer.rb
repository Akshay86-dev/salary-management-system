# frozen_string_literal: true

# Serializer for Location model
# Produces JSON:API formatted responses
class LocationSerializer
  include JSONAPI::Serializer

  attributes :name, :address, :city, :state, :zip_code, :country, :latitude, :longitude

  attribute :full_address do |location|
    location.full_address
  end

  attribute :formatted_location do |location|
    location.formatted_location
  end
end
