
module ApiConstants
  VIN_PURCHASE_TYPE = 'vin_purchase'
  VIN_REDEMPTION_TYPE = 'vin_redemption'
  MEMBERSHIP_PURCHASE_TYPE = 'mem_purchase'
  TOP_UP_PRODUCT_TYPE = 'Top-up'
  MEMBERSHIP_PRODUCT_TYPE = 'Membership'
  DELIVERY_PRODUCT_TYPE = 'Delivery'
  WINE_PRODUCT_TYPE = 'Wine'

  PAYMENT_STATUS_PENDING = 'pending'
  PAYMENT_STATUS_COMPLETE = 'complete'
  PAYMENT_STATUS_ABANDONED = 'abandoned'

  USER_INITIATED_PAYMENT_MEMO = 'user initiated payment'
  RECURRING_PAYMENT_MEMO = 'recurring payment'
  NO_PAYMENT_REQUIRED_MEMO = 'no payment required'

  module MembershipConstants
    MEMBERSHIP_TYPE_BASIC = 'basic'
    MEMBERSHIP_TYPE_SILVER = 'silver'
    MEMBERSHIP_TYPE_GOLD = 'gold'
    MEMBERSHIP_TYPE_PLATINUM = 'platinum'
  end
end