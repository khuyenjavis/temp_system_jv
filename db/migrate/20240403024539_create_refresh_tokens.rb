# frozen_string_literal: true

class CreateRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :refresh_tokens do |t|
      t.string :hashed_token_id
      t.string :hashed_refresh_token_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :refresh_tokens, :hashed_token_id, unique: true
    add_index :refresh_tokens, :hashed_refresh_token_id, unique: true
  end
end
