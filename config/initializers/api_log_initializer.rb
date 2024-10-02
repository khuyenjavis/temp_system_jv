# frozen_string_literal: true

retry_counter = 2

retry_counter.times do
  api_log_path = Rails.root.join('log', 'custom_api.log')
  API_LOGGER = Logger.new(api_log_path)
  API_LOGGER.level = Logger::DEBUG
  API_LOGGER.formatter = proc do |severity, datetime, _progname, msg|
    "API_LOGGER-[#{datetime}] #{severity} -- : #{msg}\n"
  end

  if File.exist?(api_log_path)
    Rails.logger.info '[API_LOGGER] log file created'
    break
  else
    Rails.logger.error "[API_LOGGER] log file wasn't created"
  end
rescue StandardError => e
  Rails.logger.error "[API_LOGGER] Failed to initialize custom_api.log: #{e.message}"
end

# Depend on the way of logging. We add the middleware before Rails::Rack::Logger
# require 'request_logger_middleware'
# Rails.application.config.middleware.insert_before Rails::Rack::Logger, ::RequestLoggerMiddleware
