# frozen_string_literal: true

# == Schema Information
#
# Table name: refresh_tokens
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  hashed_refresh_token_id :string
#  hashed_token_id         :string
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_refresh_tokens_on_hashed_refresh_token_id  (hashed_refresh_token_id) UNIQUE
#  index_refresh_tokens_on_hashed_token_id          (hashed_token_id) UNIQUE
#  index_refresh_tokens_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class RefreshToken < ApplicationRecord
  belongs_to :user, optional: true

  def digest!(token, type: 'refresh_token')
    if type == 'token'
      self.hashed_token_id = self.class.digest token
    else
      self.hashed_refresh_token_id = self.class.digest token
    end
    save!
  end

  def self.authenticate(token, type: 'refresh_token')
    if type == 'token'
      find_by(hashed_token_id: digest(token))
    else
      find_by(hashed_refresh_token_id: digest(token))
    end
  end

  def self.digest(token)
    Digest::SHA1.hexdigest token.to_s
  end
end
