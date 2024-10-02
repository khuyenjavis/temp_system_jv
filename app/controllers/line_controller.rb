# frozen_string_literal: true

class LineController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:destroy]
  before_action :authorize_user

  def authorize_user
    auth_header = params[:access_token].presence || request.headers['Authorization'].to_s.split(' ').last
    @auth ||= JsonWebToken.decode(auth_header)
    @user_login = @auth ? User.find_by(id: @auth[:user_id]) : nil
  end

  def destroy
    # Logic cho việc xóa
  end
end
