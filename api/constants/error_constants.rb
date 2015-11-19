module ErrorConstants

  module ApiErrors
    # Error numbers!
    THIRD_PARTY_USER_CREATION_ERROR = 'User could not be created on 3rd party'
    THIRD_PARTY_USER_ALREADY_EXISTS_ERROR = 'User already exists on 3rd party'
    THIRD_PARTY_USER_REQUEST_ERROR = 'User could not be retrieved from 3rd party'
    THIRD_PARTY_ORDER_CREATION_ERROR = 'Order could not be created on 3rd party'
    THIRD_PARTY_ORDER_UPDATE_ERROR = 'Order status could not be updated on 3rd party'
    THIRD_PARTY_PRODUCT_REQUEST_ERROR = 'Products could not be retrieved from 3rd party'
    THIRD_PARTY_CATEGORY_REQUEST_ERROR = 'Categories could not be retrieved from 3rd party'
    THIRD_PARTY_DELIVERY_REQUEST_ERROR = 'Delivery request error'
    THIRD_PARTY_PAYMENT_REQUEST_ERROR = 'Payment request error'
    THIRD_PARTY_PAYMENT_CHECKOUT_ID_REQUEST_FAIL = 'Payment checkout id request failed'
    THIRD_PARTY_PAYMENT_CHECKOUT_STATUS_REQUEST_FAIL = 'Payment checkout status request failed'
    THIRD_PARTY_REPEATED_PAYMENT_REQUEST_FAIL = 'Repeated payment request failed'
    UNRECOGNISED_PAYMENT_TYPE = 'Unrecognised payment type'
    INSUFFICIENT_VINOS = 'You do not have enough VINOS'
    INVALID_PRODUCT = 'Invalid product selected'
    INVALID_TOP_UP_OR_MEMBERSHIP_PRODUCT = 'Invalid top-up or membership product'
    PRODUCT_NOT_IN_STOCK = 'Product is not in stock'
    INVALID_USERNAME = 'Invalid username'
    OUT_OF_HOURS_ORDER_ERROR = 'The order cannot be processed out of trading hours'
    INSUFFICIENT_STOCK_QUANTITY = 'Insufficient stock quantity'
    # ORDER_CREATION_ERROR = 'Order creation error on third party'
    OUTSIDE_DELIVERY_HOURS_ERROR = 'VINOS cannot be redeemed outside delivery hours'

  end

  module ValidationErrors
    NO_DATA_FOUND = 'No data found!'
    NO_PRODUCTS_FOUND = 'No products found!'
    NO_LOCATION_FOUND = 'No location found!'
    INVALID_USER_ID = 'Invalid user id'
    INVALID_TYPE = 'Invalid type'
    INVALID_PRODUCT_ID = 'Invalid product id'
    INVALID_QUANTITY = 'Invalid product quantity'
    INVALID_EXTERNAL_USER_ID = 'Invalid external user id'
    INVALID_EMAIL = 'Invalid user email'
    INVALID_FIRST_NAME = 'Invalid user first name'
    INVALID_LAST_NAME = 'Invalid user last name'
    INVALID_USERNAME = 'Invalid username'
    INVALID_NOTES = 'Invalid characters in notes'
    INVALID_ADDRESS = 'Invalid address'
  end
end