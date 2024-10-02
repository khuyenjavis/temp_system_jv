# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 8, scale: 2
      t.integer :tax, default: 1
      t.integer :discount_type, default: 1
      t.integer :status, default: 1
      t.integer :quantity, default: 1
      t.integer :size, default: 1
      t.string :sku
      t.integer :colors_variant, default: 1
      t.integer :brand, default: 1
      t.bigint :category_id
      t.bigint :sub_category_id
      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end
