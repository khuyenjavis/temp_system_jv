# frozen_string_literal: true

class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.integer :order_id
      t.string :shipping_first_name
      t.string :shipping_middle_name
      t.string :shipping_last_name
      t.string :shipping_email
      t.string :shipping_phone
      t.string :shipping_alternative_number
      t.string :shipping_city
      t.string :shipping_street
      t.string :shipping_state
      t.string :shipping_country
      t.string :shipping_zipcode
      t.string :payment_date
      t.string :invoice_date
      t.string :invoice_number
      t.string :payment_id
      t.integer :status, default: 0
      t.integer :payment_type, default: 0
      t.decimal :subtotal, precision: 8, scale: 2
      t.decimal :total, precision: 8, scale: 2
      t.decimal :tax, precision: 8, scale: 2
      t.decimal :discount, precision: 8, scale: 2
      t.decimal :shipping_cost, precision: 8, scale: 2

      t.timestamps
    end
  end
end
