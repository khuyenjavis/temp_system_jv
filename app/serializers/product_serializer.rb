# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id              :bigint           not null, primary key
#  brand           :integer          default("brand_one")
#  colors_variant  :integer          default("white")
#  description     :text
#  discount_type   :integer          default("percentage")
#  name            :string
#  price           :decimal(8, 2)
#  quantity        :integer          default(1)
#  size            :integer          default("small")
#  sku             :string
#  status          :integer          default("inactive")
#  tax             :integer          default("tax_ten")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_id     :bigint
#  sub_category_id :bigint
#
# Indexes
#
#  index_products_on_sku  (sku) UNIQUE
#
class ProductSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :description,
             :price,
             :tax,
             :discount_type,
             :status,
             :quantity,
             :size,
             :sku,
             :colors_variant,
             :brand,
             :image_url

  delegate :image_url, to: :object

  belongs_to :category
  belongs_to :sub_category, class_name: 'Category'
end
