require 'date'
require 'json'
require 'ig-validator-utils'
require './api/errors/validation_error'
require './api/constants/error_constants'

class ApiValidator
  include ErrorConstants::ValidationErrors
  include ValidatorUtils

  def validate_user_details(data)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      #fields
      errors.push INVALID_EXTERNAL_USER_ID unless GeneralValidator.validate_string data[:id]
      errors.push INVALID_EMAIL unless GeneralValidator.validate_email data[:email]
      errors.push INVALID_FIRST_NAME unless GeneralValidator.validate_string data[:first_name]
      errors.push INVALID_LAST_NAME unless GeneralValidator.validate_string data[:last_name]
      errors.push INVALID_USERNAME unless GeneralValidator.validate_string data[:username]

      raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end
  end

  def validate_order(data)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      #fields
      # errors.push INVALID_USER_ID unless GeneralValidator.validate_string_strict data[:user_id]
      # errors.push INVALID_TYPE unless GeneralValidator.validate_string data[:type]

      if (!data[:type].to_s.downcase == 'vin_purchase') || (!data[:type].to_s.downcase == 'vin_redemption') ||
          (!data[:type].to_s.downcase == 'mem_purchase')
        errors.push INVALID_TYPE
      end

      errors.push NO_PRODUCTS_FOUND if data[:products] == nil || data[:products].count == 0

      data[:products].each do |item|
        errors.push INVALID_PRODUCT_ID unless GeneralValidator.validate_string item[:product_id]
        errors.push INVALID_QUANTITY unless (GeneralValidator.validate_integer(item[:quantity]) && (item[:quantity].to_i > 0))
      end

      if data[:type].to_s.downcase == 'vin_redemption'
        errors.push NO_LOCATION_FOUND if data[:location] == nil || data[:location][:address].to_s == ''
        errors.push INVALID_ADDRESS unless GeneralValidator.validate_address data[:location][:address]
      end
    end

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

end