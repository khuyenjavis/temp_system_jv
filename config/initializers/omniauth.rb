# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = %i[get post]
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line, ENV['LINE_LOGIN_CHANNEL_ID'], ENV['LINE_LOGIN_CHANNEL_SECRET'],
           callback_url: "#{ENV['BASE_URL']}/auth/line/callback", provider_ignores_state: true
end

OmniAuth.config.full_host = lambda do |_|
  ENV['BASE_URL'].to_s
end

OmniAuth.config.on_failure = proc do |env|
  Line::SessionsController.action(:omniauth_failure).call(env)
end
