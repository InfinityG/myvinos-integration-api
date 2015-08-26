require './api/gateways/delivery_gateway'

class DeliveryService
  def initialize(delivery_gateway = DeliveryGateway)
    @delivery_gateway = delivery_gateway.new
  end

  def send_delivery_request(user, order)
    delivery_response = @delivery_gateway.send_delivery_request(user, order)
    raise ApiError, DELIVERY_REQUEST_ERROR if delivery_response.response_code != 200

    JSON.parse(delivery_response.response_body, :symbolize_names => true)
  end
end