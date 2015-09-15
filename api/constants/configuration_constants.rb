require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => '0.0.0.0',
        :port => 8005,
        :api_auth_token => '7b2ebe64dc9149ac8a9e923bf2a6b233',
        :shared_aes_key => 'cTuRGAfCc7gsmGpWyiHBXBVEye6dP3OPV3JU+DOVPX8=',
        :id_provider_public_ecdsa_key => 'AkdyUz/yTgwDoWgy9kCkeTVDoUU2czxhM/CehQGHBh4S',
        :mongo_host => 'localhost',
        :mongo_port => 27017,
        :mongo_db => 'myvinos-db',
        :cache_timeout => 18000,
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => 'http://localhost:63342',
        :default_crypto_currency => 'VINOS',
        :default_fiat_currency => 'ZAR',
        :exchange_rate => 0.1,
        :product_api_uri => 'https://myvinos.club/wc-api/v3',
        :product_api_key => 'ck_defdc28e7f32261550d7e5bcf46cda52924210cd',
        :product_api_secret => 'cs_b2fb672e3258da45e75d5ec52d3a195347074c5a',
        :payment_api_uri => 'https://test.oppwa.com/v1',
        :payment_api_user_id => 'ff808081392eb9b201392f0b6d0200a3',
        :payment_api_password => 'wCJFfx6F',
        :payment_api_entity_id => 'ff808081392eb9b201392f0bfe3800a9',
        :payment_pending_codes => ['000.200.000', '000.200.100'],
        :payment_success_codes => ['000.000.000', '000.100.110','000.100.111','000.100.112'],
        :delivery_api_uri => 'https://api.wumdrop.com/v1',
        :delivery_api_key => '50fda008ccd3863e2a8e65a65212c9d52ebb43c2cd3d897efb771376',
        :delivery_pickup_address => "111 Saint George's Mall, Cape Town, 8001",
        :delivery_pickup_coords => '-33.92421, 18.420020000000022',
        :delivery_pickup_contact_name => 'MyVinos Dispatch',
        :delivery_pickup_contact_phone => '0787860307'
    }

    TEST = {
        :host => '0.0.0.0',
        :port => 8005,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :shared_aes_key => ENV['SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_PROVIDER_PUBLIC_KEY'],
        :mongo_host => '10.0.1.47',
        :mongo_port => 27017,
        :mongo_db => 'myvinos-db',
        :cache_timeout => 18000,
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :default_crypto_currency => 'VINOS',
        :default_fiat_currency => 'ZAR',
        :exchange_rate => 0.1,
        :product_api_uri => 'https://myvinos.club/wc-api/v2',
        :product_api_key => ENV['PRODUCT_API_KEY'],
        :product_api_secret => ENV['PRODUCT_API_SECRET'],
        :payment_api_uri => 'https://test.oppwa.com/v1',
        :payment_api_user_id => ENV['PAYMENT_API_USER_ID'],
        :payment_api_password => ENV['PAYMENT_API_PASSWORD'],
        :payment_api_entity_id => ENV['PAYMENT_API_ENTITY_ID'],
        :payment_pending_codes => ['000.200.000'],
        :payment_success_codes => ['000.000.000','000.400.000','000.400.010','000.400.020','000.400.040','000.400.050','000.400.060','000.400.070','000.400.080','000.400.090'],
        :delivery_api_uri => 'https://api.wumdrop.com/v1',
        :delivery_api_key => ENV['DELIVERY_API_KEY'],
        :delivery_pickup_address => "111 Saint George's Mall, Cape Town, 8001",
        :delivery_pickup_coords => '-33.92421, 18.420020000000022',
        :delivery_pickup_contact_name => 'MyVinos Dispatch',
        :delivery_pickup_contact_phone => '0787860307'
    }

    PRODUCTION = {
        :host => '0.0.0.0',
        :port => 8005,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :shared_aes_key => ENV['SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_PROVIDER_PUBLIC_KEY'],
        :mongo_host => '10.0.1.47',
        :mongo_port => 27017,
        :mongo_db => 'myvinos-db',
        :cache_timeout => 18000,
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :default_crypto_currency => 'VINOS',
        :default_fiat_currency => 'ZAR',
        :exchange_rate => 0.1,
        :product_api_uri => 'https://myvinos.club/wc-api/v2',
        :product_api_key => ENV['PRODUCT_API_KEY'],
        :product_api_secret => ENV['PRODUCT_API_SECRET'],
        :payment_api_uri => 'https://test.oppwa.com/v1',
        :payment_api_user_id => ENV['PAYMENT_API_USER_ID'],
        :payment_api_password => ENV['PAYMENT_API_PASSWORD'],
        :payment_api_entity_id => ENV['PAYMENT_API_ENTITY_ID'],
        :payment_pending_codes => ['000.200.000'],
        :payment_success_codes => ['000.000.000','000.400.000','000.400.010','000.400.020','000.400.040','000.400.050','000.400.060','000.400.070','000.400.080','000.400.090'],
        :delivery_api_uri => 'https://api.wumdrop.com/v1',
        :delivery_api_key => ENV['DELIVERY_API_KEY'],
        :delivery_pickup_address => "111 Saint George's Mall, Cape Town, 8001",
        :delivery_pickup_coords => '-33.92421, 18.420020000000022',
        :delivery_pickup_contact_name => 'MyVinos Dispatch',
        :delivery_pickup_contact_phone => '0787860307'
    }
  end
end