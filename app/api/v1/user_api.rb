# frozen_string_literal: true

module V1
  class UserApi < Grape::API
    before { authenticate! }

    resources :users do
      desc 'GET api/v1/users'
      params do
        optional :q, type: Hash do
          optional :email_cont
        end
        optional :page, type: Integer, default: 1
        optional :per, type: Integer, default: 10
      end
      get do
        query = User.ransack(params[:q])
        query.sorts = 'created_at desc' if query.sorts.empty?
        users = query.result.page(params[:page]).per(params[:per])
        user_serializer = users.map do |user|
          UserSerializer.new(user)
        end
        render_success(ResponseStatus::SUCCESS, I18n.t('users.list.success'), user_serializer.as_json, users)
      end

      desc 'GET api/v1/users/:id'
      params do
        requires :id, type: Integer, message: I18n.t('users.id.required')
      end
      get ':id' do
        user = User.find(params[:id])
        user_serializer = UserSerializer.new(user)
        render_success(ResponseStatus::SUCCESS, I18n.t('users.detail.success'), user_serializer.as_json)
      end

      desc 'POST api/v1/users'
      params do
        requires :user_name, type: String, message: I18n.t('users.user_name.required')
        requires :phone_number, type: String, message: I18n.t('users.phone_number.required')
        requires :address, type: String, message: I18n.t('users.address.required')
        requires :email, type: String, message: I18n.t('users.email.required')
        optional :avatar_file, type: File
        optional :note, type: String
        optional :first_name, type: String
        optional :last_name, type: String
        optional :middle_name, type: String
        optional :alternative_number, type: String
        optional :country, type: String
        optional :state, type: String
        optional :zipcode, type: String
      end
      post do
        user = User.new(params_user)
        image = params[:avatar_file]
        if image.present?
          user.avatar_file.attach(
            io: image[:tempfile],
            filename: image[:filename],
            content_type: image[:type]
          )
        end
        user.save!
        user_serializer = UserSerializer.new(user)
        render_success(ResponseStatus::SUCCESS, I18n.t('users.create.success'), user_serializer)
      end

      desc 'PUT api/v1/users/:id'
      params do
        requires :id, type: Integer, message: I18n.t('users.id.required')
        optional :email, type: String
        optional :user_name, type: String
        optional :address, type: String
        optional :note, type: String
        optional :phone_number, type: String
        optional :avatar_file, type: File
        optional :first_name, type: String
        optional :last_name, type: String
        optional :middle_name, type: String
        optional :alternative_number, type: String
        optional :country, type: String
        optional :state, type: String
        optional :zipcode, type: String
      end
      put ':id' do
        user = User.find(params[:id])
        image = params[:avatar_file]
        if image.present?
          file = ActiveStorage::Blob.find_signed(user.avatar_file.signed_id)
          file.attachments.first.purge if file.present?
          user.avatar_file.attach(
            io: image[:tempfile],
            filename: image[:filename],
            content_type: image[:type]
          )
        end
        user.update!(params_user)
        user_serializer = UserSerializer.new(user)
        render_success(ResponseStatus::SUCCESS, I18n.t('users.update.success'), user_serializer)
      end

      desc 'DELETE api/v1/users/:id'
      params do
        requires :id, type: Integer, message: I18n.t('users.id.required')
      end
      delete ':id' do
        user = User.find(params[:id])
        user.destroy!
        render_success(ResponseStatus::SUCCESS, I18n.t('users.delete.success'), true)
      end
    end

    helpers do
      def params_user
        params.slice(:user_name, :email, :phone_number, :address, :note, :first_name, :last_name, :middle_name,
                     :alternative_number, :state, :country, :zipcode)
      end
    end
  end
end
