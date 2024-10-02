# frozen_string_literal: true

class AddMoreFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :middle_name, :string
    add_column :users, :alternative_number, :string
    add_column :users, :state, :string
    add_column :users, :country, :string
    add_column :users, :zipcode, :string
  end
end
