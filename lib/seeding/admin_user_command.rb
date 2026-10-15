# frozen_string_literal: true

module Seeding
  class AdminUserCommand
    def call
      puts "\n3/6: Seeding admin user..."

      if User.human_resource.exists?
        puts "  HR users already exist (#{User.human_resource.count} records)"
        return
      end

      password = admin_password
      admin = User.create!(
        email: "admin@salarymgmt.com",
        password: password,
        password_confirmation: password,
        first_name: "Admin",
        last_name: "User",
        role: :human_resource
      )

      puts "  Created admin user: #{admin.email}"
    end

    private

    def admin_password
      if Rails.env.production?
        return ENV.fetch("SEED_ADMIN_PASSWORD") do
          raise "Set SEED_ADMIN_PASSWORD before seeding the production admin user."
        end
      end

      ENV.fetch("SEED_ADMIN_PASSWORD", "password123")
    end
  end
end
