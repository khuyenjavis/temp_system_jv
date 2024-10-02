# frozen_string_literal: true

module V1
  class SessionApi < Grape::API
    # helpers do
    #   def params_register
    #     params.slice(:first_name, :last_name, :phone_number, :email, :password)
    #   end
    # end

    desc 'POST api/v1/login'
    params do
      requires :email, type: String
      requires :password, type: String
    end
    post :login do
      user = User.find_by(email: params[:email])
      if user&.valid_password?(params[:password]) && !user&.locked
        if user&.locked
          # Add more log if need
          write_error_log('users.login', nil, message_data: { user_info: params[:email] })

          render_error(I18n.t('login.error.ban'), ResponseStatus::UNAUTHORIZED)
        else
          data = user.generate_jwt

          # Add more log if need
          write_success_log('users.login', nil, message_data: { user_info: [user.id, user.email].join(', ') })

          render_success(ResponseStatus::SUCCESS, I18n.t('login.success'), data)
        end
      else
        # Add more log if need
        write_error_log('users.login', nil, message_data: { user_info: params[:email] })

        render_error(I18n.t('login.error.username_password'), ResponseStatus::UNPROCESSABLE_ENTITY)
      end
    rescue StandardError => e
      render_error(e.message, ResponseStatus::INTERNAL_SERVER_ERROR)
    end

    resource :admin do
      desc 'POST api/v1/admin/login'
      params do
        requires :email, type: String
        requires :password, type: String
      end
      post :login do
        user = User.admin.find_by(email: params[:email])
        if user&.valid_password?(params[:password]) && !user&.locked
          if user&.locked
            render_error(I18n.t('login.error.ban'), ResponseStatus::UNAUTHORIZED)
          else
            data = user.generate_jwt
            render_success(ResponseStatus::SUCCESS, I18n.t('login.success'), data)
          end
        else
          render_error(I18n.t('login.error.username_password'), ResponseStatus::UNAUTHORIZED)
        end
      rescue StandardError => e
        render_error(e.message, ResponseStatus::INTERNAL_SERVER_ERROR)
      end
    end

    desc 'POST api/v1/register'
    params do
      requires :first_name, type: String, message: I18n.t('users.first_name.required')
      requires :last_name, type: String, message: I18n.t('users.last_name.required')
      requires :phone_number, type: String, message: I18n.t('users.phone.required')
      requires :email, type: String, message: I18n.t('users.email.required')
      requires :password, type: String, message: I18n.t('users.password.required')
    end
    post :register do
      params_register = params.slice(:first_name, :last_name, :phone_number, :email, :password)
      user = User.new(params_register)
      user.save!
      user_serializer = UserSerializer.new(user)
      render_success(ResponseStatus::SUCCESS, I18n.t('users.create.success'), user_serializer)
    end

    desc 'POST api/v1/reset_password'
    params do
      requires :email, type: String
    end
    post :reset_password do
      user = User.find_by(email: params[:email])
      if user
        ResetPasswordJob.perform_later(user)
        data = { processed: true }
        render_success(ResponseStatus::SUCCESS, I18n.t('reset_password.success'), data)
      else
        render_error(I18n.t('reset_password.error.invalid'), ResponseStatus::NOT_FOUND)
      end
    rescue StandardError => e
      render_error(e.message, ResponseStatus::INTERNAL_SERVER_ERROR)
    end

    desc 'put api/v1/update_password'
    params do
      requires :password, type: String, message: I18n.t('change_password.error.password_blank')
      requires :token, type: String, message: I18n.t('change_password.error.token_blank')
    end
    put :update_password do
      token = Devise.token_generator.digest(User, :reset_password_token, params[:token])
      user = User.find_by(reset_password_token: token)
      if user.present?
        if (Time.current.to_i - user.reset_password_sent_at.to_i) < User::VALID_RESET_PW_TOKEN_TIME
          user.update(password: params[:password])
          render_success(ResponseStatus::SUCCESS, I18n.t('update_password.success'), true)
        else
          render_error(I18n.t('change_password.error.token_expired'), ResponseStatus::NOT_FOUND)
        end
      else
        render_error(I18n.t('change_password.error.token_invalid'), ResponseStatus::NOT_FOUND)
      end
    rescue StandardError => e
      render_error(e.message, ResponseStatus::INTERNAL_SERVER_ERROR)
    end

    desc 'DELETE api/v1/logout'
    delete :logout do
      authenticate!
      begin
        ActiveRecord::Base.transaction do
          AuthenticationToken.authenticate(@token).destroy
          RefreshToken.authenticate(@token, type: 'token').destroy
        end
        render_success(ResponseStatus::SUCCESS, I18n.t('logout.success'), true)
      rescue StandardError => e
        render_error(e.message, ResponseStatus::INTERNAL_SERVER_ERROR)
      end
    end

    desc 'post api/v1/refresh_token'
    post :refresh_token do
      required_refresh_token!

      begin
        user = User.find_by(email: refresh_token_data[0]['email'])
        data = user.generate_jwt('refresh_token')
        authen_token = AuthenticationToken.find_by(hashed_id: @refresh_token.hashed_token_id)
        authen_token.destroy if authen_token.present?
        render_success(ResponseStatus::SUCCESS, I18n.t('refresh_token.success'), data)
      rescue StandardError => e
        render_error(e.message, ResponseStatus::INTERNAL_SERVER_ERROR)
      end
    end
  end
end
