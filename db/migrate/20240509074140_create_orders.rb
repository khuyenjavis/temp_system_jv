# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.decimal :subtotal, precision: 8, scale: 2
      t.decimal :total, precision: 8, scale: 2
      t.decimal :tax, precision: 8, scale: 2
      t.decimal :discount, precision: 8, scale: 2
      t.decimal :shipping_cost, precision: 8, scale: 2
      t.datetime :estimate_delivery_date
      t.integer :status, default: 1

      t.timestamps
    end
  end
end
