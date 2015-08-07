require 'date'
require 'json'
require 'ig-validator-utils'
require './api/errors/validation_error'
require './api/constants/error_constants'

class ApiValidator
  include ErrorConstants::ValidationErrors
  include ValidatorUtils

  def validate_order(data)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      #fields
      # errors.push INVALID_USER_ID unless GeneralValidator.validate_string_strict data[:user_id]
      # errors.push INVALID_TYPE unless GeneralValidator.validate_string data[:type]
      errors.push INVALID_TYPE if data[:type].to_s.downcase != ('vin_purchase' || 'vin_redemption')
      errors.push NO_PRODUCTS_FOUND if data[:products] == nil || data[:products].count == 0

      data[:products].each do |item|
        errors.push INVALID_PRODUCT_ID unless GeneralValidator.validate_string item[:product_id]
        errors.push INVALID_QUANTITY unless GeneralValidator.validate_integer item[:quantity]
      end

      raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end
  end

end