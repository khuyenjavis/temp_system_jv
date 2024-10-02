# frozen_string_literal: true

module JsonWebToken
  SECRET_KEY = ENV['SECRET_KEY'] || Rails.application.secrets.secret_key_base

  class << self
    def encode(payload)
      payload['exp'] = (Time.current + 24.hours).to_i

      JWT.encode(payload, SECRET_KEY)
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new decoded
    rescue StandardError
      nil
    end
  end
end
