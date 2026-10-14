# frozen_string_literal: true

# JWT blacklist model for token revocation in devise-jwt auth
# Uses the built-in Denylist revocation strategy from devise-jwt
# Tokens are revoked on logout by adding them to this blacklist table
class JwtBlacklist < ApplicationRecord
  # Use the built-in denylist revocation strategy from devise-jwt
  # This allows tokens to be revoked on logout, making them invalid before their expiration
  include Devise::JWT::RevocationStrategies::Denylist
end
