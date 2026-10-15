# frozen_string_literal: true

module Seeding
  class DepartmentManagerCommand
    def call
      puts "\n6/6: Assigning department managers..."

      Department.find_each do |department|
        manager = User.active.where(department_id: department.id).order(Arel.sql("RANDOM()")).first
        next unless manager

        department.update!(manager_id: manager.id)
        puts "  #{department.name} -> #{manager.full_name}"
      end
    end
  end
end
