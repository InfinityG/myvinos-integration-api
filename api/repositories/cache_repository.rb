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
                                 :product_type => product[:product_type],
                                 :supplier => product[:supplier],
                                 :brand => product[:brand],
                                 :price => product[:price],
                                 :currency => product[:currency],
                                 :name => product[:name],
                                 :description => product[:description],
                                 :image_url => product[:image_url],
                                 :tags => product[:tags])
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

  def get_product(id)
    products = get_products

    products.each do |product|
      return product if product.product_id == id
    end if products != nil

    nil
  end
end