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
class Product < ApplicationRecord
  include ApiCommon

  enum status: { inactive: 1, active: 2 }
  enum discount_type: { percentage: 1, amount: 2 }
  enum size: { small: 1, medium: 2, large: 3 }
  enum colors_variant: { white: 1, red: 2, blue: 3, green: 4 }
  enum brand: { brand_one: 1, brand_two: 2, brand_three: 3 }
  enum tax: { tax_ten: 1, tax_eight: 2 }

  # Add the validations for the Product Model here
  validates :name, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true

  belongs_to :category
  belongs_to :sub_category, class_name: 'Category'

  has_one_attached :image
  validates :image, content_type: [:png, :jpg, :jpeg]

  def self.ransackable_attributes(_auth_object = nil)
    %w[brand category_id colors_variant created_at description discount_type id name price quantity size sku
       status sub_category_id tax updated_at]
  end

  def image_url
    Rails.application.routes.url_helpers.url_for(image) if image.attached?
  end
end
