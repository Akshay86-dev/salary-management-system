# frozen_string_literal: true

# User model for authentication
# Handles Devise authentication for the salary management system
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :timeoutable, :trackable

  # Associations
  has_many :audits, dependent: :destroy

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  # Scopes
  scope :ordered, -> { order(:last_name, :first_name) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end
end
