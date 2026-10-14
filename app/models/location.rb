# frozen_string_literal: true

# Location model for salary management system
# Represents physical locations where employees work
class Location < ApplicationRecord
  # Associations
  has_many :employees

  # Validations
  validates :name, presence: true
  validates :country, presence: true, inclusion: { in: %w[USA Canada Mexico UK] }

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :by_state, ->(state) { where(state: state) }
  scope :search, ->(query) {
    where('lower(name) LIKE :q OR lower(city) LIKE :q OR lower(state) LIKE :q',
          q: "%#{query.to_s.downcase}%")
  }

  # Instance methods
  def full_address
    parts = [address, city, state, zip_code].compact
    return name if parts.empty?
    parts.join(', ')
  end

  def formatted_location
    "#{name}, #{city}, #{state} #{zip_code}"
  end
end
