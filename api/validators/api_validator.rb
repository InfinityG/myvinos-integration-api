require 'date'
require 'json'
require './api/errors/validation_error'
require './api/constants/error_constants'

class ApiValidator
  include ErrorConstants::ValidationErrors
  include ValidatorUtils

  def validate_order(data)
    # {
    #     "user_id": "6236",
    #     "type": "vin_purchase",
    #     "line_items": [
    #                  {
    #                      "product_id": "123",
    #                      "quantity": 25,
    #                  }
    #              ]
    # }

    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      #fields
      errors.push INVALID_USER_ID unless GeneralValidator.validate_string_strict data[:user_id]
      errors.push INVALID_TYPE unless GeneralValidator.validate_string_strict data[:type]
      errors.push INVALID_TYPE if data[:type].to_s.downcase != 'vin_purchase' || data[:type].to_s.downcase != 'vin_redemption'
      errors.push INVALID_LINE_ITEMS if data[:line_items] == nil || data[:line_items].count == 0

      data[:line_items].each do |item|
        errors.push INVALID_PRODUCT_ID unless GeneralValidator.validate_string item[:product_id]
        errors.push INVALID_QUANTITY unless GeneralValidator.validate_integer item[:quantity]
      end

      raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end
  end

end