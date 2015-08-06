require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => '0.0.0.0',
        :port => 8005,
        :api_auth_token => '7b2ebe64dc9149ac8a9e923bf2a6b233',
        :shared_aes_key => 'Pomro4n7AEng/jdeOCucRcOnXok/HKgY/hzLQyuL1xM=',
        :id_provider_public_ecdsa_key => 'A1blXQkf5AH7pfNNx2MIwNXytCyV/wxmQOt7ZGgccvVQ',
        :mongo_host => 'localhost',
        :mongo_port => 27017,
        :mongo_db => 'myvinos-db',
        :cache_timeout => 18000,
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => 'http://localhost:63342',
        :default_crypto_currency => 'VIN',
        :default_fiat_currency => 'ZAR',
        :exchange_rate => 0.1,
        :product_api_uri => 'https://myvinos.club/wc-api/v2',
        :product_api_key => 'ck_e7b70d96f2f469c0e29ebe7ba6ea90a2',
        :product_api_secret => 'cs_140148e48a6658ee33565b6d9c2a58ea',
        :payment_api_uri => 'https://test.oppwa.com/v1',
        :payment_api_user_id => 'ff808081392eb9b201392f0b6d0200a3',
        :payment_api_password => 'wCJFfx6F',
        :payment_api_entity_id => 'ff808081392eb9b201392f0bfe3800a9',
        :payment_pending_codes => ['000.200.100'],
        :payment_success_codes => ['000.100.110','000.100.111','000.100.112'],
        :delivery_api_uri => 'https://myvinos.club/wc-api/v2',
        :delivery_api_key => 'ck_e7b70d96f2f469c0e29ebe7ba6ea90a2',
        :delivery_api_secret => 'cs_140148e48a6658ee33565b6d9c2a58ea',
    }

    TEST = {
        :host => '0.0.0.0',
        :port => 8002,
        # :ssl_cert_path => '/etc/ssl/certs/server.crt',
        # :ssl_private_key_path => '/etc/ssl/private/server.key',
        :api_auth_token => '7b2ebe64dc9149ac8a9e923bf2a6b233',
        :shared_aes_key => 'Pomro4n7AEng/jdeOCucRcOnXok/HKgY/hzLQyuL1xM=',
        :id_provider_public_ecdsa_key => 'A1blXQkf5AH7pfNNx2MIwNXytCyV/wxmQOt7ZGgccvVQ',
        :mongo_host => 'localhost',
        :mongo_port => 27017,
        :mongo_db => 'myvinos-db',
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*'
    }

    # PRODUCTION = {
    #     :host => '10.0.0.208',
    #     :port => 8002,
    #     :ssl_cert_path => '/etc/ssl/certs/server.crt',
    #     :ssl_private_key_path => '/etc/ssl/private/server.key',
    #     :api_auth_token => 'f20298dddd5142be9616b15baee5da9c',
    #     :admin_username => 'admin',
    #     :admin_password => '12billyBob!*/',
    #     :mongo_host => '10.0.1.46',
    #     :mongo_port => 27017,
    #     :mongo_db => 'contracts',
    #     :mongo_db_user => 'contractsUser',
    #     :mongo_db_password => 'g4f1jh4g1234!',
    #     :logger_file => 'app_log.log',
    #     :logger_age => 10,
    #     :logger_size => 1024000,
    #     :default_request_timeout => 60,
    #     :allowed_origin => 'localhost'
    #     # :static => true,
    #     # :public_folder => 'docs'
    # }
  end
end