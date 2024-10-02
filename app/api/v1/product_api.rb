# frozen_string_literal: true

module V1
  class ProductApi < Grape::API
    before { authenticate! }

    resources :products do
      desc 'GET api/v1/products'
      params do
        optional :q, type: Hash do
          optional :name_cont
        end
        optional :page, type: Integer, default: 1
        optional :per, type: Integer, default: 10
      end
      get do
        query = Product.ransack(params[:q])
        query.sorts = 'created_at desc' if query.sorts.empty?
        products = query.result.page(params[:page]).per(params[:per])
        product_serializer = products.map do |product|
          ProductSerializer.new(product)
        end
        render_success(ResponseStatus::SUCCESS, I18n.t('products.list.success'), product_serializer.as_json, products)
      end

      desc 'GET api/v1/products/:id'
      params do
        requires :id, type: Integer, message: I18n.t('products.id.required')
      end
      get ':id' do
        product = Product.find(params[:id])
        product_serializer = ProductSerializer.new(product)
        render_success(ResponseStatus::SUCCESS, I18n.t('products.detail.success'), product_serializer.as_json)
      end

      desc 'POST api/v1/products'
      params do
        requires :name, type: String, desc: 'Product name'
        requires :description, type: String, desc: 'Product description'
        requires :price, type: BigDecimal, desc: 'Product price'
        requires :tax, type: String, desc: 'Product tax'
        requires :discount_type, type: String, desc: 'Product discount type'
        requires :status, type: String, desc: 'Product status'
        requires :quantity, type: Integer, desc: 'Product quantity'
        requires :size, type: String, desc: 'Product size'
        requires :sku, type: String, desc: 'Product SKU'
        requires :colors_variant, type: String, desc: 'Product colors variant'
        requires :brand, type: String, desc: 'Product brand'
        requires :category_id, type: Integer, desc: 'Category ID'
        requires :sub_category_id, type: Integer, desc: 'Sub Category ID'
        optional :image, type: File
      end
      post do
        product = Product.new(params_product)
        image = params[:image]
        if image.present?
          Product.image.attach(
            io: image[:tempfile],
            filename: image[:filename],
            content_type: image[:type]
          )
        end
        product.save!
        product_serializer = ProductSerializer.new(product)
        render_success(ResponseStatus::SUCCESS, I18n.t('products.create.success'), product_serializer)
      end

      desc 'PUT api/v1/products/:id'
      params do
        requires :id, type: Integer, message: I18n.t('products.id.required')
        optional :name, type: String, desc: 'Product name'
        optional :description, type: String, desc: 'Product description'
        optional :price, type: BigDecimal, desc: 'Product price'
        optional :tax, type: String, desc: 'Product tax'
        optional :discount_type, type: String, desc: 'Product discount type'
        optional :status, type: String, desc: 'Product status'
        optional :quantity, type: Integer, desc: 'Product quantity'
        optional :size, type: String, desc: 'Product size'
        optional :sku, type: String, desc: 'Product SKU'
        optional :colors_variant, type: String, desc: 'Product colors variant'
        optional :brand, type: String, desc: 'Product brand'
        optional :category_id, type: Integer, desc: 'Category ID'
        optional :sub_category_id, type: Integer, desc: 'Sub Category ID'
        optional :image, type: File
      end
      put ':id' do
        product = Product.find(params[:id])
        image = params[:image]
        if image.present?
          file = ActiveStorage::Blob.find_signed(product.avatar_file.signed_id)
          file.attachments.first.purge if file.present?
          product.avatar_file.attach(
            io: image[:tempfile],
            filename: image[:filename],
            content_type: image[:type]
          )
        end
        product.update!(params_Product)
        product_serializer = ProductSerializer.new(product)
        render_success(ResponseStatus::SUCCESS, I18n.t('products.update.success'), product_serializer)
      end

      desc 'DELETE api/v1/products/:id'
      params do
        requires :id, type: Integer, message: I18n.t('products.id.required')
      end
      delete ':id' do
        product = Product.find(params[:id])
        product.destroy!
        render_success(ResponseStatus::SUCCESS, I18n.t('products.delete.success'), true)
      end
    end

    helpers do
      def params_product
        params.slice(:name, :description, :price, :tax, :discount_type, :status, :quantity, :size, :sku,
                     :colors_variant, :brand, :category_id, :sub_category_id)
      end
    end
  end
end
