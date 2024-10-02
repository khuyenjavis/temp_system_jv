# frozen_string_literal: true

class CreateAuthenticationTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :authentication_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :hashed_id

      t.timestamps
    end
    add_index :authentication_tokens, :hashed_id, unique: true
  end
end
