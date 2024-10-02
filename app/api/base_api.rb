# frozen_string_literal: true

class BaseApi < Grape::API
  mount V1::AppApi
  add_swagger_documentation mount_path: '/link-api-docs'
end
