# frozen_string_literal: true

module ResponseStatus
  SUCCESS = 200
  CREATED_SUCCESS = 201
  BAD_REQUEST = 400
  UNAUTHORIZED = 401
  NOT_FOUND = 404
  FORBIDDEN = 403
  UNPROCESSABLE_ENTITY = 422
  INTERNAL_SERVER_ERROR = 500
  RESPONSE_MESSAGE = { '200' => 'success', '400' => 'bad_request',
                       '401' => 'unauthorized', '422' => 'unprocessable_entity',
                       '403' => 'forbidden', '500' => 'internal_server_error' }.freeze
end
