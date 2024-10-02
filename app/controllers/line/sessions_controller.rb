# frozen_string_literal: true

module Line
  class SessionsController < LineController
    skip_before_action :verify_authenticity_token

    def verify_current_user
      auth_header = params[:access_token].presence || request.headers['Authorization'].to_s.split(' ').last
      @auth ||= JsonWebToken.decode(auth_header)

      current_user = User.find_by(id: @auth[:user_id]) if @auth
      render json: {
        current_user: current_user.as_json(
          only: [:id, :name, :email]
        )
      }
    end

    def callback
      auth = request.env['omniauth.auth']
      if auth.present?
        user = User.from_omniauth(auth)
        access_token = JsonWebToken.encode({ user_id: user.id })

        redirect_to("#{ENV['CLIENT_URL']}/line?access_token=#{access_token}", allow_other_host: true)
      else
        redirect_to("#{ENV['CLIENT_URL']}/line", allow_other_host: true)
      end
    rescue StandardError => e
      Rails.logger.info "=======ERROR=======#{e.message}"
      render json: {
        error: e.message
      }, status: :bad_request
    end

    def omniauth_failure
      Rails.logger.info "EEERRRROOOO #{params}"
      redirect_to("#{ENV['CLIENT_URL']}/line", allow_other_host: true)
    end

    def new_session
      Rails.logger.info '=======ERROR======= new_session ====='
      redirect_to("#{ENV['CLIENT_URL']}/line", allow_other_host: true)
    end
  end
end
