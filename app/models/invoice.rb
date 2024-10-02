# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                          :bigint           not null, primary key
#  discount                    :decimal(8, 2)
#  invoice_date                :string
#  invoice_number              :string
#  payment_date                :string
#  payment_type                :integer          default("cash")
#  shipping_alternative_number :string
#  shipping_city               :string
#  shipping_cost               :decimal(8, 2)
#  shipping_country            :string
#  shipping_email              :string
#  shipping_first_name         :string
#  shipping_last_name          :string
#  shipping_middle_name        :string
#  shipping_phone              :string
#  shipping_state              :string
#  shipping_street             :string
#  shipping_zipcode            :string
#  status                      :integer          default("unpaid")
#  subtotal                    :decimal(8, 2)
#  tax                         :decimal(8, 2)
#  total                       :decimal(8, 2)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  order_id                    :integer
#  payment_intent_id           :string
#
class Invoice < ApplicationRecord
  belongs_to :order
  enum status: {
    unpaid: 0,
    paid: 1
  }
  enum payment_type: {
    cash: 0,
    stripe: 1
  }
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at discount id invoice_date invoice_number order_id payment_date payment_type
       shipping_alternative_number shipping_city shipping_cost shipping_country shipping_email shipping_first_name
       shipping_last_name shipping_middle_name shipping_phone shipping_state shipping_street shipping_zipcode status
       subtotal tax total updated_at]
  end
end
