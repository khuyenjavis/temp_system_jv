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
require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
