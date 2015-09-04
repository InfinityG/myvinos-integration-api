require 'rest_client'
require 'uri'
require 'net/https'
require 'openssl'

class RestUtil

  def execute_get(api_uri, auth_header)
    puts "Uri: #{api_uri}"

    client = RestClient::Resource.new api_uri
    response = client.get(:content_type => 'application/json;charset=UTF-8',
                          :verify_ssl => false,
                          :Authorization => auth_header)

    build_response(response)
  end

  def execute_post(api_uri, auth_header, json = '')
    puts "Request uri: #{api_uri}"
    puts "Request JSON: #{json}"

    # client = get_client api_uri, true
    client = RestClient::Resource.new api_uri

    response = begin
      client.post(json,
                  :content_type => 'application/json;charset=UTF-8',
                  :verify_ssl => false,
                  :Authorization => auth_header)
    rescue => e
      return build_response e.response
    end

    build_response(response)
  end

  def execute_post_with_cert(api_uri, auth_header, json = '')
    puts "Request uri: #{api_uri}"
    puts "Request JSON: #{json}"

    # client = get_client api_uri, true
    client = RestClient::Resource.new api_uri

    response = begin
      client.post(json,
                  :content_type => 'application/json;charset=UTF-8',
                  :verify_ssl => OpenSSL::SSL::VERIFY_PEER,
                  :ssl_ca_file  =>  OpenSSL::X509::DEFAULT_CERT_FILE,
                  :Authorization => auth_header)
    rescue => e
      return build_response e.response
    end

    build_response(response)
  end

  def execute_form_post(uri, auth_header, payload = '')
    puts "Request uri: #{uri}"
    puts "Request body: #{payload}"

    response = begin
      uri = URI(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(payload)

      http.request(req)
    rescue => e
      return build_response e.response
    end

    build_response(response)
  end

  def build_response(response)
    rest_response = RestResponse.new
    rest_response.response_code = response.code.to_i
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