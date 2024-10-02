# frozen_string_literal: true

GrapeSwaggerRails.options.app_name      = 'Docs APIs'
GrapeSwaggerRails.options.url           = '/api/link-api-docs'
GrapeSwaggerRails.options.doc_expansion = 'list'
GrapeSwaggerRails.options.hide_api_key_input = false
GrapeSwaggerRails.options.hide_url_input = false

GrapeSwaggerRails.options.before_action do
  unless Rails.env.test?
    # authenticate_or_request_with_http_basic('Application') do |name, password|
    #   name == 'admin' && password == '123456789'
    # end
  end

  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
end

GrapeSwaggerRails.options.api_auth      = 'bearer' # Or 'basic' for OAuth
GrapeSwaggerRails.options.api_key_name  = 'Authorization'
GrapeSwaggerRails.options.api_key_type  = 'header'

# GrapeSwaggerRails.options.display_request_duration = true
# GrapeSwaggerRails.options.filter = true
# GrapeSwaggerRails.options.headers['Special-Header'] = 'Some Secret Value'
