require 'json'
require 'minitest'
require_relative '../../../api/utils/rest_util'
require_relative '../../../tests/config'

Given(/^I have an authentication token$/) do
  # a token for 'john doe' expiring August 2016
  # idio_token = {
  #     :'token' => 'c6796a87-b478-4f05-a17d-ca7acf0ef4aa',
  #     :'auth' => "Fpd5uYr5QHaC27iAnaPzTkKw4dJIzAxW3J8pRZAtcJaG1kMKvWmHEo8O11Qi\nGfmr4gsgsiJofMbl8Su24XRa4Werm2bSKq4Z7cqNnXUx3jXiG/zdVu8gkwZN\n0aePCBYxeZ1MVm0SwIPHW8ev4aSMTjZie2aHCv3n7WJq5TweMzISMwV0qx7d\nkJieKtnUB2CL9JI6QuY4qGjGKKTIGsoc2uVtxDiyJY8mkIZufG1FlDWQ7OI1\nPFnfod63BzClvSY/jeiox68l9Szj2IA47Uh65dJIEaR6eCYeta1ZyPxqZ3BO\nKviJ8Q+ysZ3NhO9DrYWEs+GYlVglB2JxioNxEAT2QbCsIwx5vpuqC3WSlAQ2\nejsv2eWOOd1R5rCvMlxOxXR0daTBxAh9T0wZmLkD5s9Lvbq4G96a2POg1l8E\nU3Ip4wNxgscSZnxjskEI/IpmqUKSXuh0dDifeV7PbYm8ScHXGknn3ojnDOgJ\nHOEK/57PxaiTnp5b0YtjD3n/obmr4GS2Y+hoSDfX4QpiLm3XeDqxdgtq9G2X\nWqqGCjd0BNKremM=\n",
  #     :'iv' => "VuPVin2NXn2h09U/iBMeJw==\n"
  # }.to_json

  idio_token = {
      :token => "b567f702-b698-4332-8dc3-d1a8ad18f10b",
      :auth => "/LGVozeJC4R4zu8H+N10IGxrP/F7V+oIKRzH93LDT3I6/as9ZlmZrQf2QrVD\nPL/L22FHbs73r4LpE6P61rRQrGjAlIUzimV1aADiokSlGXAHhL1UJ1+V9w6k\nyvNpw40gPmzSMbq84sbJWcty/8NGJWRi3mU3IgOm1ryLazQdYZnh8CNE9KXk\nze4s9CK1vLGh59MAYeQGRoJj1l07W7TuqkKAgAQEGe6fE/YsAE/l6fPKglcO\nb2u2dVoNFvHwd6EbrNNnxk7Oe2hx7M1xWtSgn11HLdGPOYjOiO+5COCSwO3M\nRjaB2Zzcc/j29gitkD2BjSMGa/ZSxtbmPHk9AoUByRUqE0EJrSYK2ct2bUVI\nHeIfPxAZ/57UlNHAnNU34RIHsNaV72EJgtMWvc77aOsCCqaSu3DLpHaMJ3mL\nEFcgBnrmU6ZGmgakQaX/F+oPeV807RuyalyL5ol2KQdyFukWKMXPwVv8wwLr\nuaqvSfmRpIIZYLPUmFl7UXVGoHgEZjCl1kb3CwaG634BT61XkNi1xyHLNPKI\n6W95zy9BqHfzGMFR4Qem9Y4IY/qL6Nw61t0qwOMFZl8aJKs2xxvOuFVTnQw5\nEhSDfQ73Sb9wuZs9L10x6B6KPFc+lxIh87HDQ7oBIpUzDYYNWBWQnJTa9JLe\ndmMTEVdTCFOD0VGVY6zNXjNzREukshve8iFspK1kvNjaKkBTuQDkwnLM0yx4\nmsxJn1mJ0XrTOpyHCM4MTc+WyrLtJVbpKd6IeU5jh090mCK3\n",
      :iv => "eCl9MxEYDYO6ZQELMfG/2Q==\n"
  }.to_json

  puts 'Creating login token'
  response = RestUtil.new.execute_post(MYVINOS_API_URI + '/tokens', nil, idio_token)
  puts "Login result: #{response.response_body}"
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