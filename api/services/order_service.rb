require './api/services/log_service'

class OrderService
  include LogService

  def initialize()
  end

  # {
  #     "user_id": "6236",
  #     "type": "vin_purchase",
  #     "line_items": [
  #                  {
  #                      "product_id": "123",
  #                      "quantity": 25,
  #                  }
  #              ]
  #
  # }

  def create_order(type, line_items)
    user_id = @current_user.id

    # VIN PURCHASE
    # 1. create order record
    # 2. create checkout id on Peach Payments
    # 3. create transaction record with checkout id
    # 4. update order record with transaction
    # 5. return order with checkout id
    # 6. poll to check order status while app completes transaction
    # 7. update transaction status to complete
    # 8. UPDATE BALANCE (CREDIT VIN)

    # # VIN REDEMPTION
    # 1. check user balance
    # 2. check product availability (?)
    # 3. create order on WooCommerce
    # 4. create order (local) and set external_order_id
    # 5. create transaction record
    # 6. update order record with transaction
    # 7. UPDATE BALANCE (DEBIT VIN)

    case type
      when 'vin_purchase'

      when 'vin_redemption'

      else

    end

    log(user_id, 'Order', order.id, 'create_order', "Create #{type} order")

  end
end