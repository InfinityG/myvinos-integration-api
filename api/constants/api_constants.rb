
module ApiConstants
  VIN_PURCHASE_TYPE = 'vin_purchase'
  VIN_REDEMPTION_TYPE = 'vin_redemption'
  VIN_TOP_UP_TYPE = 'vin_topup'
  VIN_PROMO_TYPE = 'vin_promo'
  VIN_CREDIT_TYPE = 'vin_credit'
  MEMBERSHIP_PURCHASE_TYPE = 'mem_purchase'

  TOP_UP_PRODUCT_TYPE = 'Top-up'
  MEMBERSHIP_PRODUCT_TYPE = 'Membership'
  DELIVERY_PRODUCT_TYPE = 'Delivery'
  WINE_PRODUCT_TYPE = 'Wine'
  CREDIT_PRODUCT_TYPE = 'Credit'

  PAYMENT_STATUS_PENDING = 'pending'
  PAYMENT_STATUS_COMPLETE = 'complete'
  PAYMENT_STATUS_ABANDONED = 'abandoned'

  USER_INITIATED_PAYMENT_MEMO = 'user initiated payment'
  RECURRING_PAYMENT_MEMO = 'recurring payment'
  NO_PAYMENT_REQUIRED_MEMO = 'no payment required'
  TOP_UP_PAYMENT_MEMO = 'top-up'
  VIN_BONUS_MEMO = 'vinos credit'

  module MembershipConstants
    MEMBERSHIP_TYPE_BASIC = 'basic'
    MEMBERSHIP_TYPE_SILVER = 'silver'
    MEMBERSHIP_TYPE_GOLD = 'gold'
    MEMBERSHIP_TYPE_PLATINUM = 'platinum'
    MEMBERSHIP_TYPES = [MEMBERSHIP_TYPE_BASIC, MEMBERSHIP_TYPE_GOLD, MEMBERSHIP_TYPE_PLATINUM, MEMBERSHIP_TYPE_SILVER]
  end

  module OperationConstants
    USER_BALANCE_UPDATE = 'user balance update'
  end
end