# frozen_string_literal: true

require "test_helper"
require_relative "../../../lib/seeding/configuration"

class Seeding::ConfigurationTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "profiles inherit shared seed settings and override employee count" do
    assert_equal 100, Seeding::Configuration.for_profile(:small).fetch(:employee_count)
    assert_equal 10_000, Seeding::Configuration.for_profile("default").fetch(:employee_count)
    assert_equal 50_000, Seeding::Configuration.for_profile(:large).fetch(:employee_count)
    assert_equal 1_000, Seeding::Configuration.for_profile(:small).fetch(:employee_batch_size)
  end

  test "unknown profiles raise an actionable error" do
    error = assert_raises(ArgumentError) do
      Seeding::Configuration.for_profile(:unknown)
    end

    assert_includes error.message, "small, default, large"
  end
end
