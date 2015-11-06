require 'mongo_mapper'
require 'bson'
require './api/models/user'
require './api/models/card'

class CardRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def create(user_id, registration_id, last_4_digits, holder, expiry_month, expiry_year, default)

      Card.create(:user_id => user_id,
                  :registration_id => registration_id,
                  :last_4_digits => last_4_digits,
                  :holder => holder,
                  :expiry_month => expiry_month,
                  :expiry_year => expiry_year,
                  :default => default)

  end

  def get_card_by_registration_id(registration_id)
    Card.where(:registration_id => registration_id).first
  end

  def get_cards_for_user(user_id)
    Card.where(:user_id => user_id).all
  end

end