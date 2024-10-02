# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def reset_password(user)
    token = user.generate_reset_password_token
    @email = user.email
    @reset_password_url = ENV['FE_APP_URL'] + "/reset_password?token=#{token}"
    mail(to: @email, subject: 'Reset password')
  end
end
