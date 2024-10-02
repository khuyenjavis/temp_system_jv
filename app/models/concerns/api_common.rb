# frozen_string_literal: true

module ApiCommon
  extend ActiveSupport::Concern

  VALID_RESET_PW_TOKEN_TIME = 15.minutes.to_i

  def generate_jwt(option = 'token')
    token_expired_at = 2.hours.from_now.to_i
    payload_token = {
      id:,
      email:,
      exp: token_expired_at,
      type: 'token'
    }
    access_token = JWT.encode(payload_token, Rails.application.credentials.secret_key_base)
    authentication_token = authentication_tokens.create
    authentication_token.digest!(access_token)
    ouput_data = { access_token:, token_expired_at: }
    if option == 'token'
      refresh_token_expired_at = 7.days.from_now.to_i
      refresh_token_payload = {
        id:,
        email:,
        exp: refresh_token_expired_at,
        type: 'refresh_token'
      }
      refresh_token_key = JWT.encode(refresh_token_payload, Rails.application.credentials.secret_key_base)
      refresh_token = refresh_tokens.create
      refresh_token.digest!(access_token, type: 'token')
      refresh_token.digest!(refresh_token_key, type: 'refresh_token')

      ouput_data[:refresh_token] = refresh_token_key
      ouput_data[:refresh_token_expired_at] = refresh_token_expired_at
    else
      refresh_tokens.first.digest!(access_token, type: 'token')
    end

    ouput_data
  end

  def generate_reset_password_token
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    self.reset_password_token = hashed
    self.reset_password_sent_at = Time.current
    save
    raw
  end
end
