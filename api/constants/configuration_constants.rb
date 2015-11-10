require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => '0.0.0.0',
        :port => 8005,
        :force_ascii_conversion => true,
        :api_auth_token => ENV['MV_API_AUTH_TOKEN'],
        :shared_aes_key => ENV['MV_SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_PROVIDER_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => nil,
        :mongo_host_3 => nil,
        :mongo_db => ENV['MONGO_DB'],
        :cache_timeout => 300,
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => 'http://localhost:63342',
        :default_crypto_currency => 'VINOS',
        :default_fiat_currency => 'ZAR',
        :exchange_rate => 0.1,
        :signup_credit_enabled => true,
        :default_signup_credit => 5,
        :product_api_uri => 'https://myvinos.club/wc-api/v3',
        :product_api_key => ENV['MV_PRODUCT_API_KEY'],
        :product_api_secret => ENV['MV_PRODUCT_API_SECRET'],
        :payment_api_uri => 'https://test.oppwa.com/v1',
        :payment_widget_uri => 'https://test.oppwa.com/v1/paymentWidgets.js?checkoutId=',
        :payment_api_user_id => ENV['MV_PAYMENT_API_USER_ID'],
        :payment_api_password => ENV['MV_PAYMENT_API_PASSWORD'],
        :payment_api_entity_id => ENV['MV_PAYMENT_API_ENTITY_ID'],
        :payment_pending_codes => ['000.200.000', '000.200.100'],
        :payment_success_codes => ['000.000.000', '000.100.110','000.100.111','000.100.112'],
        :purchase_order_timeout => 300,
        :minimum_delivery_amount => 30,
        :minimum_delivery_active => false,
        :delivery_api_uri => 'https://api.wumdrop.com/v1',
        :delivery_api_key => ENV['MV_DELIVERY_API_KEY'],
        :delivery_pickup_address => "111 Saint George's Mall, Cape Town, 8001",
        :delivery_pickup_coords => '-33.92421, 18.420020000000022',
        :delivery_pickup_contact_name => 'MyVinos',
        :delivery_pickup_contact_phone => '0787860307',
        :time_zone => 'Harare',
        :trading_days => [1,2,3,4,5,6],
        :trading_hours_active => false,
        :trading_hours_start => 9,
        :trading_hours_end => 18,
        :delivery_hours_active => true,
        :delivery_hours_start => 12,
        :delivery_hours_end => 22
    }

    TEST = {
        :host => '0.0.0.0',
        :port => 8005,
        :force_ascii_conversion => true,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :shared_aes_key => ENV['SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_PROVIDER_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => nil,
        :mongo_host_3 => nil,
        :mongo_db => ENV['MONGO_DB'],
        :cache_timeout => 300,
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :default_crypto_currency => 'VINOS',
        :default_fiat_currency => 'ZAR',
        :exchange_rate => 0.1,
        :signup_credit_enabled => true,
        :default_signup_credit => 5,
        :product_api_uri => 'https://myvinos.club/wc-api/v3',
        :product_api_key => ENV['PRODUCT_API_KEY'],
        :product_api_secret => ENV['PRODUCT_API_SECRET'],
        :payment_api_uri => 'https://test.oppwa.com/v1',
        :payment_widget_uri => 'https://test.oppwa.com/v1/paymentWidgets.js?checkoutId=',
        :payment_api_user_id => ENV['PAYMENT_API_USER_ID'],
        :payment_api_password => ENV['PAYMENT_API_PASSWORD'],
        :payment_api_entity_id => ENV['PAYMENT_API_ENTITY_ID'],
        :payment_pending_codes => ['000.200.000','000.200.100'],
        :payment_success_codes => ['000.000.000', '000.100.110','000.100.111','000.100.112','000.400.000','000.400.010','000.400.020','000.400.040','000.400.050','000.400.060','000.400.070','000.400.080','000.400.090'],
        :purchase_order_timeout => 300,
        :minimum_delivery_amount => 30,
        :minimum_delivery_active => false,
        :delivery_api_uri => 'https://api.wumdrop.com/v1',
        :delivery_api_key => ENV['DELIVERY_API_KEY'],
        :delivery_pickup_address => "111 Saint George's Mall, Cape Town, 8001",
        :delivery_pickup_coords => '-33.92421, 18.420020000000022',
        :delivery_pickup_contact_name => 'MyVinos',
        :delivery_pickup_contact_phone => '0787860307',
        :time_zone => 'Harare',
        :trading_days => [1,2,3,4,5,6],
        :trading_hours_active => false,
        :trading_hours_start => 9,
        :trading_hours_end => 18,
        :delivery_hours_active => true,
        :delivery_hours_start => 12,
        :delivery_hours_end => 22
    }

    PRODUCTION = {
        :host => '0.0.0.0',
        :port => 8005,
        :force_ascii_conversion => true,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :shared_aes_key => ENV['SHARED_AES_KEY'],
        :id_provider_public_ecdsa_key => ENV['ID_PROVIDER_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => ENV['MONGO_HOST_2'],
        :mongo_host_3 => ENV['MONGO_HOST_3'],
        :mongo_db => ENV['MONGO_DB'],
        :cache_timeout => 300,
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :default_crypto_currency => 'VINOS',
        :default_fiat_currency => 'ZAR',
        :exchange_rate => 0.1,
        :signup_credit_enabled => true,
        :default_signup_credit => 5,
        :product_api_uri => 'https://myvinos.club/wc-api/v3',
        :product_api_key => ENV['PRODUCT_API_KEY'],
        :product_api_secret => ENV['PRODUCT_API_SECRET'],
        :payment_api_uri => 'https://oppwa.com/v1',
        :payment_widget_uri => 'https://oppwa.com/v1/paymentWidgets.js?checkoutId=',
        :payment_api_user_id => ENV['PAYMENT_API_USER_ID'],
        :payment_api_password => ENV['PAYMENT_API_PASSWORD'],
        :payment_api_entity_id => ENV['PAYMENT_API_ENTITY_ID'],
        :payment_pending_codes => ['000.200.000','000.200.100'],
        :payment_success_codes => ['000.000.000','000.100.110','000.100.111','000.100.112','000.400.000','000.400.010','000.400.020','000.400.040','000.400.050','000.400.060','000.400.070','000.400.080','000.400.090'],
        :purchase_order_timeout => 300,
        :minimum_delivery_amount => 30,
        :minimum_delivery_active => false,
        :delivery_api_uri => 'https://api.wumdrop.com/v1',
        :delivery_api_key => ENV['DELIVERY_API_KEY'],
        :delivery_pickup_address => "111 Saint George's Mall, Cape Town, 8001",
        :delivery_pickup_coords => '-33.92421, 18.420020000000022',
        :delivery_pickup_contact_name => 'MyVinos',
        :delivery_pickup_contact_phone => '0787860307',
        :time_zone => 'Harare',
        :trading_days => [1,2,3,4,5,6],
        :trading_hours_active => true,
        :trading_hours_start => 9,
        :trading_hours_end => 18,
        :delivery_hours_active => true,
        :delivery_hours_start => 12,
        :delivery_hours_end => 22
    }
  end
end