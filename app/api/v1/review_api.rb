# frozen_string_literal: true

module V1
  class ReviewApi < Grape::API
    before { authenticate! }

    resources :reviews do
      desc 'GET api/v1/reviews'
      params do
        optional :q, type: Hash do
          optional :title_cont
        end
        optional :page, type: Integer, default: 1
        optional :per, type: Integer, default: 10
      end
      get do
        query = Review.ransack(params[:q])
        query.sorts = 'created_at desc' if query.sorts.empty?
        reviews = query.result.page(params[:page]).per(params[:per])
        review_serializer = reviews.map do |review|
          ReviewSerializer.new(review)
        end
        render_success(ResponseStatus::SUCCESS, I18n.t('reviews.list.success'), review_serializer.as_json, reviews)
      end

      desc 'GET api/v1/reviews/:id'
      params do
        requires :id, type: Integer, message: I18n.t('reviews.id.required')
      end
      get ':id' do
        review = Review.find(params[:id])
        review_serializer = ReviewSerializer.new(review)
        render_success(ResponseStatus::SUCCESS, I18n.t('reviews.detail.success'), review_serializer.as_json)
      end

      desc 'POST api/v1/reviews'
      params do
        requires :title, type: String, desc: 'review title'
        optional :description, type: String, desc: 'review description'
        requires :rating, type: Integer, desc: 'review rating'
        optional :review_date, type: DateTime, desc: 'review date'
        requires :product_id, type: Integer, desc: 'product id'
      end
      post do
        review = current_user.reviews.new(params_review)
        review.save!
        review_serializer = ReviewSerializer.new(review)
        render_success(ResponseStatus::SUCCESS, I18n.t('reviews.create.success'), review_serializer)
      end

      desc 'PUT api/v1/reviews/:id'
      params do
        requires :id, type: Integer, message: I18n.t('reviews.id.required')
        optional :title, type: String, desc: 'review title'
        optional :description, type: String, desc: 'review description'
        optional :rating, type: Integer, desc: 'review rating'
        optional :review_date, type: DateTime, desc: 'review date'
        optional :product_id, type: Integer, desc: 'product id'
      end
      put ':id' do
        review = current_user.reviews.find(params[:id])
        review.update!(params_review)
        review_serializer = ReviewSerializer.new(review)
        render_success(ResponseStatus::SUCCESS, I18n.t('reviews.update.success'), review_serializer)
      end

      desc 'DELETE api/v1/reviews/:id'
      params do
        requires :id, type: Integer, message: I18n.t('reviews.id.required')
      end
      delete ':id' do
        review = Review.find(params[:id])
        review.destroy!
        render_success(ResponseStatus::SUCCESS, I18n.t('reviews.delete.success'), true)
      end
    end

    helpers do
      def params_review
        params.slice(:title, :description, :rating, :review_date, :product_id)
      end
    end
  end
end
