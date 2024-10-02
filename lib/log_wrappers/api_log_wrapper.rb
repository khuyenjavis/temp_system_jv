# frozen_string_literal: true

module ApiLogWrapper
  def with_log!(log_key = nil, options = {})
    @log_data = {}
    yield if block_given?
    process_log(@log_data, log_key, options)
  rescue ActiveRecord::RecordInvalid => e
    API_LOGGER.error "\t#{error_log(log_key, e.record.errors.full_messages.join('|'), options)}"
    raise e
  rescue StandardError => e
    API_LOGGER.error "\t#{error_log(log_key, e.message, options)}"
    API_LOGGER.error "\t#{error_log(log_key, e.backtrace, options)}"
    raise e
  end

  def request_log(log_data, log_key, options)
    log_name = log_key ? message_id(log_key) : nil
    request_data = log_data[:request]
    headers = log_data[:headers]
    filter_params = ActiveSupport::ParameterFilter.new([:password, 'Authorization'])

    API_LOGGER.info "#{'-' * 7} [#{Time.zone.now}] [#{system_id(options)}] [#{program_name(options)}] [START_LOGGING_ON #{log_name}: #{request_data.request_method} #{request_data.path}]"
    API_LOGGER.info "\t[#{Time.zone.now}] [#{system_id(options)}] [#{program_name(options)}] [REQUEST_HEADERS: #{filter_params.filter(headers.dup)}"
    API_LOGGER.info "\t[#{Time.zone.now}] [#{system_id(options)}] [#{program_name(options)}] [REQUEST_PARAMETERS: #{filter_params.filter(request_data.params)}"
  end

  def write_error_log(log_key, message, options = {})
    API_LOGGER.error "\t#{error_log(log_key, message, options)}"
  end

  def write_success_log(log_key, message, options = {})
    API_LOGGER.info "\t#{success_log(log_key, message, options)}"
  end

  private

  def process_log(log_data, log_key, options)
    return API_LOGGER.info 'No log data to log' if log_data.blank?

    log_from = log_data[:log_from].to_sym
    case log_from
    when :middleware
      middleware_log(log_data, log_key, options)
    else
      raise 'Unsupportted log or required log_from in log data for logging'
    end
  end

  def middleware_log(log_data, log_key, options)
    results_log(log_data, log_key, options)
  end

  def results_log(log_data, log_key, options)
    status = log_data[:status]
    response_data = log_data[:response]

    if status >= 500
      API_LOGGER.fatal "\t#{error_log(log_key, response_data, options)}"
    elsif status >= 400 && status < 500
      API_LOGGER.error "\t#{error_log(log_key, response_data, options)}"
    else
      API_LOGGER.info "\t#{success_log(log_key, response_data.slice('message'), options)}"
    end
  end

  def error_log(log_key, message, options = {})
    [
      "[#{Time.zone.now}]",
      "[#{system_id(options)}]",
      "[#{program_name(options)}]",
      "[#{message_id(log_key)}_FAILED:",
      "#{message || build_log_message(log_key, :failed, options)}]"
    ].join(' ')
  end

  def success_log(log_key, message, options = {})
    [
      "[#{Time.zone.now}]",
      "[#{system_id(options)}]",
      "[#{program_name(options)}]",
      "[#{message_id(log_key)}_SUCCESS:",
      "#{message || build_log_message(log_key, :success, options)}]"
    ].join(' ')
  end

  def system_id(options = {})
    return options[:system_id] if options[:system_id]

    begin
      Rails.application.name
    rescue StandardError
      Rails.application.class.name.split('::')[0]
    end
  end

  def program_name(options)
    options[:program_name] || ''
  end

  def message_id(key_chains)
    return nil unless key_chains

    I18n.t("api_log_keys.#{key_chains}")
  end

  def build_log_message(log_key, type, options = {})
    return unless log_key

    options[:message_data] ||= {}

    I18n.t("api_log_messages.#{log_key}.#{type}", options[:message_data])
  rescue StandardError
    I18n.t("api_log_messages.#{log_key}.#{type}")
  end
end
