# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                     :bigint           not null, primary key
#  discount               :decimal(8, 2)
#  estimate_delivery_date :datetime
#  shipping_cost          :decimal(8, 2)
#  status                 :integer          default("book")
#  subtotal               :decimal(8, 2)
#  tax                    :decimal(8, 2)
#  total                  :decimal(8, 2)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Order < ApplicationRecord
  has_many :order_items
  has_many :products, through: :order_items
  has_one :invoice
  accepts_nested_attributes_for :order_items, allow_destroy: true
  enum status: { book: 1, checked_in: 2, cancelled: 3, checked_out: 4, draft: 5 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at discount estimate_delivery_date id shipping_cost status subtotal tax total updated_at]
  end
end
