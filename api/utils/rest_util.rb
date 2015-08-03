require 'rest_client'

class RestUtil

  def execute_get(api_uri, auth_header)
    puts "Uri: #{api_uri}"

    client = RestClient::Resource.new api_uri
    response = client.get(:content_type => 'application/json;charset=UTF-8', :verify_ssl => false, :Authorization => auth_header)

    build_response(response)
  end

  def execute_post(api_uri, auth_header, json = '')
    puts "Request uri: #{api_uri}"
    puts "Request JSON: #{json}"

    # client = get_client api_uri, true
    client = RestClient::Resource.new api_uri

    response = begin
      client.post(json, :content_type => 'application/json;charset=UTF-8', :verify_ssl => false,  :Authorization => auth_header)
    rescue => e
      return build_response e.response
    end

    build_response(response)
  end

  def build_response(response)
    rest_response = RestResponse.new
    rest_response.response_code = response.code
    rest_response.response_body = response.body

    puts "Response code: #{response.code}"
    # puts "Response JSON: #{response.body}"
    # puts ''

    rest_response
  end

end

class RestResponse
  attr_accessor :response_code
  attr_accessor :response_body
end