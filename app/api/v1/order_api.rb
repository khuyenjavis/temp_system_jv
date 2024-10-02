# frozen_string_literal: true

module V1
  class OrderApi < Grape::API
    before { authenticate! }

    resources :orders do
      desc 'GET api/v1/orders'
      params do
        optional :q, type: Hash do
          optional :estimate_delivery_date_eq
        end
        optional :page, type: Integer, default: 1
        optional :per, type: Integer, default: 10
      end
      get do
        query = Order.ransack(params[:q])
        query.sorts = 'created_at desc' if query.sorts.empty?
        orders = query.result.page(params[:page]).per(params[:per])
        order_serializer = orders.map do |order|
          OrderSerializer.new(order)
        end
        render_success(ResponseStatus::SUCCESS, I18n.t('orders.list.success'), order_serializer.as_json, orders)
      end

      desc 'GET api/v1/orders/:id'
      params do
        requires :id, type: Integer, message: I18n.t('orders.id.required')
      end
      get ':id' do
        order = Order.find(params[:id])
        order_serializer = OrderSerializer.new(order)
        render_success(ResponseStatus::SUCCESS, I18n.t('orders.detail.success'), order_serializer.as_json)
      end

      desc 'POST api/v1/orders'
      params do
        optional :discount, type: BigDecimal, desc: 'discount'
        optional :estimate_delivery_date, type: DateTime, desc: 'estimate_delivery_date'
        optional :shipping_cost, type: BigDecimal, desc: 'shipping_cost'
        optional :tax, type: BigDecimal, desc: 'order tax'
        optional :subtotal, type: BigDecimal, desc: 'order subtotal'
        optional :status, type: String, desc: 'order status'
        optional :total, type: BigDecimal, desc: 'order total'
        requires :order_items_attributes, type: Array do
          optional :product_id, type: Integer
          requires :quantity, type: Integer
        end
      end
      post do
        order = Order.new(params)
        order.save!
        order_serializer = OrderSerializer.new(order)
        render_success(ResponseStatus::SUCCESS, I18n.t('orders.create.success'), order_serializer)
      end

      desc 'PUT api/v1/orders/:id'
      params do
        requires :id, type: Integer, message: I18n.t('orders.id.required')
        optional :discount, type: BigDecimal, desc: 'discount'
        optional :estimate_delivery_date, type: DateTime, desc: 'estimate_delivery_date'
        optional :shipping_cost, type: BigDecimal, desc: 'shipping_cost'
        optional :tax, type: BigDecimal, desc: 'order tax'
        optional :subtotal, type: BigDecimal, desc: 'order subtotal'
        optional :status, type: String, desc: 'order status'
        optional :total, type: BigDecimal, desc: 'order total'
        optional :order_items_attributes, type: Array do
          optional :product_id, type: Integer
          optional :quantity, type: Integer
        end
      end
      put ':id' do
        order = Order.find(params[:id])
        order.update!(params)
        order_serializer = OrderSerializer.new(order)
        render_success(ResponseStatus::SUCCESS, I18n.t('orders.update.success'), order_serializer)
      end

      desc 'DELETE api/v1/orders/:id'
      params do
        requires :id, type: Integer, message: I18n.t('orders.id.required')
      end
      delete ':id' do
        order = Order.find(params[:id])
        order.destroy!
        render_success(ResponseStatus::SUCCESS, I18n.t('orders.delete.success'), true)
      end
    end
  end
end
