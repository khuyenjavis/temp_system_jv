# frozen_string_literal: true

class CreateTodos < ActiveRecord::Migration[7.0]
  def change
    create_table :todos do |t|
      t.string :title
      t.datetime :start_date
      t.datetime :end_date
      t.string :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
