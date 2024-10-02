# frozen_string_literal: true

module Admin
  class UserSerializer < UserSerializer
    attributes :locked, :role
  end
end
