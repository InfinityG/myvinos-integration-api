module ErrorConstants

  module ApiErrors
    PRODUCT_REQUEST_ERROR = 'Product request error'
    PAYMENT_REQUEST_ERROR = 'Payment request error'
    PAYMENT_CHECKOUT_REQUEST_FAIL = 'Payment checkout request failed'
    PAYMENT_CHECKOUT_ID_FAIL = 'Payment checkout id creation failed'
    UNRECOGNISED_PAYMENT_TYPE = 'Unrecognised payment type'
  end

  module ValidationErrors
    NO_DATA_FOUND = 'No data found!'
    NO_PRODUCTS_FOUND = 'No products found!'
    INVALID_USER_ID = 'Invalid user id'
    INVALID_TYPE = 'Invalid type'
    INVALID_PRODUCT_ID = 'Invalid product id'
    INVALID_QUANTITY = 'Invalid product quantity'
  end
end