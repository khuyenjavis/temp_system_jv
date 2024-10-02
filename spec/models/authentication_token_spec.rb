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
require 'rails_helper'

RSpec.describe AuthenticationToken, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
