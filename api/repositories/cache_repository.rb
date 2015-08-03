require 'mongo_mapper'
require 'bson'
require './api/models/cache'
require './api/models/product'

class CacheRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def save_products(mapped_products, expires)
    product_arr = []

    mapped_products.each do |product|
      product_arr << Product.new(:product_id => product[:product_id],
                                 :title => product[:title],
                                 :description => product[:description],
                                 :farm => product[:farm],
                                 :color => product[:color],
                                 :grapes => product[:grapes],
                                 :style => product[:style],
                                 :image_url => product[:image_url])
    end

    cache = Cache.first

    if cache != nil
      cache.products = product_arr
      cache.products_expiry = expires
      cache.save
    else
      Cache.create(:products => product_arr, :products_expiry => expires)
    end

  end

  def get_products
    cache = Cache.first

    if cache != nil
      if cache.products_expiry < Time.now.to_i
        cache.products = nil
        cache.save
        return nil
      end

      return cache.products
    end

    nil

  end
end