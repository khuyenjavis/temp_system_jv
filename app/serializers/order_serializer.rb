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
class OrderSerializer < ActiveModel::Serializer
  attributes :id,
             :discount,
             :estimate_delivery_date,
             :shipping_cost,
             :tax,
             :subtotal,
             :status,
             :total

  has_many :products
end
