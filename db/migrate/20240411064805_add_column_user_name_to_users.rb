# frozen_string_literal: true

class AddColumnUserNameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_name, :string, after: :created_at
    add_column :users, :address, :string, after: :created_at
    add_column :users, :note, :string, after: :created_at
  end
end
