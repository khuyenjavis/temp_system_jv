# frozen_string_literal: true

require 'api_log_wrapper'

class RequestLoggerMiddleware
  include ::ApiLogWrapper

  def initialize(app)
    @app = app
  end

  def call(env)
    @request = ActionDispatch::Request.new(env)

    with_log! do
      request_data = {
        request: @request,
        headers: get_headers(env)
      }
      request_log(request_data, nil, {})

      @status, @headers, @response = @app.call(env)

      @log_data = {
        log_from: :middleware,
        request: @request,
        status: @status,
        headers: @headers,
        response: parse_response(@response)
      }
    end

    [@status, @headers, @response]
  end

  def get_headers(env)
    Hash[*env.select { |k, _v| k.start_with? 'HTTP_' }
             .collect { |k, v| [k.sub(/^HTTP_/, ''), v] }
             .collect { |k, v| [k.split('_').collect(&:capitalize).join('-'), v] }
             .sort
             .flatten]
  end

  def parse_response(res)
    if res.is_a?(Rack::BodyProxy)
      JSON.parse(res.join)
    elsif res.is_a?(Array)
      JSON.parse(res.first)
    else
      res
    end
  end
end
