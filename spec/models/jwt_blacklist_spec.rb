require "rails_helper"

RSpec.describe JwtBlacklist, type: :model do
  it "persists a token identifier and expiration" do
    expiration = 1.day.from_now

    blacklist = described_class.create!(jti: "revoked-token", exp: expiration)

    expect(blacklist.reload.jti).to eq("revoked-token")
    expect(blacklist.exp).to be_within(1.second).of(expiration)
    expect(described_class.find_by!(jti: "revoked-token")).to eq(blacklist)
  end

  it "does not allow duplicate token identifiers" do
    described_class.create!(jti: "duplicate-token", exp: 1.day.from_now)
    duplicate = described_class.new(jti: "duplicate-token", exp: 1.day.from_now)

    expect { duplicate.save! }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "requires a token identifier and expiration in the database" do
    blacklist = described_class.new

    expect { blacklist.save! }.to raise_error(ActiveRecord::NotNullViolation)
  end

  it "includes the devise-jwt denylist strategy" do
    expect(described_class.ancestors)
      .to include(Devise::JWT::RevocationStrategies::Denylist)
  end
end
