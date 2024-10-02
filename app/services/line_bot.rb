# frozen_string_literal: true

require 'line/bot'

class LineBot
  attr_accessor :client, :line_user_id, :url

  def initialize(line_user_id = nil, url = nil)
    @line_user_id = line_user_id
    @client = set_client
    @url = url
  end

  def set_client
    Line::Bot::Client.new do |config|
      config.channel_id = ENV['LINE_CHANNEL_ID']
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def user_info
    response = client.get_profile(line_user_id)
    JSON.parse response.body
  end
end
