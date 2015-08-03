require 'date'
require 'json'
require './api/errors/validation_error'
require './api/constants/error_constants'

class ApiValidator
  include ErrorConstants::ValidationErrors
end