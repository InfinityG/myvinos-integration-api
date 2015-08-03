class ProductMapper
  def map_woo_products(products)
    # {
    #     "id": "9823",
    #     "title": "Franschoek Chamonix",
    #     "description": "Pinot Noir",
    #     "farm": "Franschoek",
    #     "color": "red",
    #     "mood_filter": "",
    #     "price": "23 VIN",
    #     "image_url": ""
    # }

    result = []

    products.each do |product|
      # farm
      farm = nil
      color = nil
      grapes = nil
      style = nil

      product[:attributes].each do |attribute|
        farm = attribute[:options][0] if attribute[:name] == 'Producer' if attribute[:options] != nil && attribute[:options].length > 0
        color = attribute[:options][0] if attribute[:name] == 'Wine' if attribute[:options] != nil && attribute[:options].length > 0
        grapes = attribute[:options][0] if attribute[:name] == 'Grapes' if attribute[:options] != nil && attribute[:options].length > 0
        style = attribute[:options][0] if attribute[:name] == 'Style' if attribute[:options] != nil && attribute[:options].length > 0
      end

      # image
      image = nil
      if product[:images] != nil && product[:images].length > 0
        image = product[:images][0][:src]
      end

      mapped_product = {
          :product_id => product[:id],
          :title => product[:title],
          :description => product[:description],
          :farm => farm,
          :color => color,
          :grapes => grapes,
          :style => style,
          :image_url => image
      }

      result << mapped_product
    end

    result
  end
end