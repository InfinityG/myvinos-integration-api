require 'securerandom'
require 'digest'

class HashGenerator

  def generate_password_hash(password, salt)
    salted_password = password + salt
    generate_hash salted_password
  end

  def generate_hash(data)
    Digest::SHA2.base64digest data
  end

  def generate_salt
    generate_uuid
  end

  def generate_uuid
    SecureRandom.uuid
  end

  def generate_random_number
    SecureRandom.random_number 500
  end

  #http://stackoverflow.com/questions/2754449/bitwise-operations-on-strings-with-ruby
  def generate_bitwise_xor

  end
end