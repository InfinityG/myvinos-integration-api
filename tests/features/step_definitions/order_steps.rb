require 'json'
require 'minitest'
require_relative '../../../api/utils/rest_util'
require_relative '../../../tests/config'

Given(/^I have an authentication token$/) do

  idio_login_payload = {
      :username => 'testuser1@myvinos.com',
      :password=> 'Password1',
      :domain=> 'myvinos',
      :fingerprint=> '9f6e26a098b8db4a09b843ca9b074ccb'
  }.to_json

  puts 'Logging in to ID-IO'
  # ca_file_path = File.expand_path('/usr/local/etc/openssl/cert.pem', __FILE__)
  response = RestUtil.new.execute_post_with_cert(MYVINOS_ID_IO_URI + '/login', nil, idio_login_payload)
  # response = RestUtil.new.execute_post(MYVINOS_ID_IO_URI + '/login', nil, idio_login_payload)
  puts "ID-IO login result: #{response.response_body}"
  puts "Response code: #{response.response_code}"

  assert response.response_code == 201

  result = JSON.parse(response.response_body, :symbolize_names => true)
  id_io_auth = result.to_json

  puts 'Creating login token'
  response = RestUtil.new.execute_post(MYVINOS_API_URI + '/tokens', nil, id_io_auth)
  puts "MyVinos login result: #{response.response_body}"
  puts "Response code: #{response.response_code}"

  assert response.response_code == 201

  result = JSON.parse(response.response_body, :symbolize_names => true)
  @auth_token = result[:token]
end

And(/^I have selected a VINOs top\-up product$/) do
  puts 'Getting products...'
  response = RestUtil.new.execute_get(MYVINOS_API_URI + '/products', @auth_token)
  puts "Products result: #{response.response_body}"
  puts "Response code: #{response.response_code}"

  products = JSON.parse(response.response_body, :symbolize_names => true)

  @selected_product = nil
  products.each do |item|
      if item[:product_type].to_s.downcase == 'top-up'
        @selected_product = item
        break
      end
    end

end

When(/^I send the order request to the API$/) do
  payload = {
      'type': 'vin_purchase',
      'currency': 'ZAR',
      'products': [
          {
              'product_id': @selected_product[:product_id],
              'quantity': 1
          }
      ]
  }.to_json

  puts 'Creating order...'
  @order_response = RestUtil.new.execute_post(MYVINOS_API_URI + '/orders', @auth_token, payload)
  puts "Products result: #{@order_response.response_body}"
  puts "Response code: #{@order_response.response_code}"
end

Then(/^the API should respond with a (\d+) response code$/) do |arg|
  assert @order_response.response_code.to_s == arg
end

And(/^the response should contain a checkout id$/) do
  body = JSON.parse(@order_response.response_body, :symbolize_names => true)
  assert body[:checkout_id] != nil
end