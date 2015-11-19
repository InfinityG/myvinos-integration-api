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

  def get_cards_for_user_redacted(user_id)
    # Card.where(:user_id => user_id).fields(:last_4_digits, :holder, :expiry_month, :expiry_year, :default).all
    # Card.find({user_id: user_id}, {last_4_digits: 1, holder: 1, expiry_month:1, expiry_year: 1, default: 1})
    Card.all :user_id => user_id, :fields => ['last_4_digits', 'holder', 'expiry_month', 'expiry_year', 'default']
  end

  def set_card_for_user(user_id, registration_id, last_4_digits, holder, expiry_month, expiry_year)
    all_cards = get_cards_for_user user_id
    card_exists = false
    result = nil

    # make the passed-in registration_id the default if it already exists
    all_cards.each do |card|
      if card.registration_id == registration_id
        result = Card.set({:id => card.id.to_s}, :default => true)
        card_exists = true
      else
        Card.set({:id => card.id.to_s}, :default => false)
      end
    end

    unless card_exists
      result = create user_id, registration_id, last_4_digits, holder, expiry_month, expiry_year, true
    end

    result
  end

end