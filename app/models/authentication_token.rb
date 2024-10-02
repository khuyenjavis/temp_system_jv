# frozen_string_literal: true

# == Schema Information
#
# Table name: authentication_tokens
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hashed_id  :string
#  user_id    :bigint           not null
#
# Indexes
#
#  index_authentication_tokens_on_hashed_id  (hashed_id) UNIQUE
#  index_authentication_tokens_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AuthenticationToken < ApplicationRecord
  belongs_to :user, optional: true

  def digest!(token)
    self.hashed_id = self.class.digest token
    save!
  end

  def self.authenticate(token)
    find_by hashed_id: digest(token)
  end

  def self.digest(token)
    Digest::SHA1.hexdigest token.to_s
  end
end
