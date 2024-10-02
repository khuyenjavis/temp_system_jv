# frozen_string_literal: true

class ResetPasswordJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.reset_password(user).deliver_now
  end
end
