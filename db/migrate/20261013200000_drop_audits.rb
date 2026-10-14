# frozen_string_literal: true

class DropAudits < ActiveRecord::Migration[8.1]
  def change
    drop_table :audits
  end
end