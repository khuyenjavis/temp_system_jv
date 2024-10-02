# frozen_string_literal: true

module V1
  class AppApi < Grape::API
    version 'v1', using: :path
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers
    insert_before Grape::Middleware::Error, RequestLoggerMiddleware

    include ::GrapeApiLogWrapper

    rescue_from ActiveRecord::InvalidForeignKey do |e|
      render_error(e.message, ResponseStatus::UNPROCESSABLE_ENTITY)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      errors = e.errors.map { |field, message| { message: message.first, field: field.first } }
      render_error(errors, ResponseStatus::UNPROCESSABLE_ENTITY)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_error("#{e.model} not found", ResponseStatus::NOT_FOUND)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      errors = e.record.errors.messages.map { |field, message| { message: message.first, field: } }
      render_error(errors, ResponseStatus::UNPROCESSABLE_ENTITY)
    end

    rescue_from ActiveRecord::RecordNotDestroyed do |_exception|
      render_error(e.message, ResponseStatus::UNPROCESSABLE_ENTITY)
    end

    namespace do
      namespace do
        mount V1::SessionApi
        mount V1::UserApi
        mount V1::TodoApi
        mount V1::ProductApi
        mount V1::ReviewApi
        mount V1::OrderApi
        mount V1::InvoiceApi
        mount V1::Admin::UserApi
      end
    end

    helpers do
      def token
        @token ||= request.headers['Authorization'].scan(/Bearer (.*)$/).flatten.last.to_s
        return nil if @token.blank? || @token.split('.').count < 2
        return nil if AuthenticationToken.authenticate(@token).blank?

        @token
      end

      def data
        JWT.decode(token, Rails.application.credentials.secret_key_base)
      rescue StandardError
        nil
      end

      def current_user
        return @current_user if @current_user
        return nil unless data

        @current_user = User.find_by(email: data.first['email'])
      end

      def authenticate!
        render_error(I18n.t('devise.failure.unauthenticated'), ResponseStatus::UNAUTHORIZED) unless current_user
      end

      def admin_authenticate!
        render_error(I18n.t('devise.failure.unauthenticated'), ResponseStatus::FORBIDDEN) unless current_user&.admin?
      end

      def line_user
        auth_header = params[:access_token].presence || request.headers['Authorization'].to_s.split(' ').last
        auth ||= JsonWebToken.decode(auth_header)

        User.find_by(id: auth[:user_id]) if auth
      end

      def line_authenticate!
        render_error(I18n.t('devise.failure.unauthenticated'), ResponseStatus::UNAUTHORIZED) unless line_user
      end

      def render_error(errors, code, message = nil)
        errors = {
          code: ResponseStatus::RESPONSE_MESSAGE[code.to_s],
          message:,
          errors:
        }
        error!(errors, code)
      end

      def render_success(code, message, data, resources = {})
        response = {
          code: ResponseStatus::RESPONSE_MESSAGE[code.to_s],
          message:,
          data: {}
        }

        if resources.present?
          meta = {
            page: params[:page].presence || 1,
            per: params[:per].presence || 10,
            total_pages: resources.total_pages,
            total_items: resources.total_count
          }
          response[:meta] = meta
          resource_name = resources.model.table_name
          response[:data][resource_name] = data
        else
          response[:data] = data
        end
        status :ok
        present response
      end

      def required_refresh_token!
        refresh_token = take_refresh_token
        unless refresh_token_data || refresh_token
          render_error(I18n.t('refresh_token.error'),
                       ResponseStatus::UNAUTHORIZED)
        end

        @refresh_token = RefreshToken.authenticate(refresh_token, type: 'refresh_token')
      end

      def take_refresh_token
        refresh_token ||= request.headers['Authorization'].scan(/Bearer (.*)$/).flatten.last.to_s
        return nil if refresh_token.blank? || refresh_token.split('.').count < 2
        return nil if RefreshToken.authenticate(refresh_token, type: 'refresh_token').blank?

        refresh_token
      end

      def refresh_token_data
        JWT.decode(take_refresh_token, Rails.application.credentials.secret_key_base)
      rescue StandardError
        nil
      end

      def valid_image?(image_file)
        filename = image_file['filename']
        file_extension = File.extname(filename)
        return false if file_extension.nil?

        file_type = file_extension[1..].downcase
        %w[jpg jpeg png].include?(file_type)
      end

      def each_serializers(objects)
        model_class = objects.klass
        serializer_class = "#{model_class}Serializer".constantize
        ActiveModel::Serializer::CollectionSerializer.new(objects, each_serializer: serializer_class)
      end

      def pagination(query_object)
        query_object.page(params[:page]).per(params[:per])
      end

      def attach_images(object, images)
        images&.each do |image|
          object.image_files.attach(
            io: image[:tempfile],
            filename: image[:filename],
            content_type: image[:type]
          )
        end
      end
    end
  end
end
