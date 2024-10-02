# frozen_string_literal: true

require 'api_log_wrapper'

module GrapeApiLogWrapper
  extend ActiveSupport::Concern

  included do
    helpers ::ApiLogWrapper
  end
end
