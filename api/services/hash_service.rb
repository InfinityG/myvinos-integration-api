require './api/utils/hash_generator'

class HashService
  def initialize(hash_generator = HashGenerator)
    @hash_generator = hash_generator.new
  end

  def generate_password_hash(password, salt)
    @hash_generator.generate_password_hash password, salt
  end

  def generate_salt
    @hash_generator.generate_salt
  end

  def generate_uuid
    @hash_generator.generate_uuid
  end
end