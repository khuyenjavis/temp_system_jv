# frozen_string_literal: true

# == Schema Information
#
# Table name: reviews
#
#  id          :bigint           not null, primary key
#  description :text
#  rating      :integer
#  review_date :datetime
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  product_id  :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_reviews_on_product_id  (product_id)
#  index_reviews_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#
class Review < ApplicationRecord
  include ApiCommon
  belongs_to :product
  belongs_to :user

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at description id product_id rating review_date title updated_at user_id]
  end
end
