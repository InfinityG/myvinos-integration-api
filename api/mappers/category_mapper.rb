require './api/services/config_service'

class CategoryMapper

  def initialize(config_service = ConfigurationService)
    @config = config_service.new.get_config
  end

  def map_categories(categories)
    result = []

    # top-level categories
    categories.each do |category|

      if category[:parent] == 0
        mapped_category = map_category(category)
        child_index = []
        build_tree(child_index, [] << mapped_category, categories)
        mapped_category[:child_index] = child_index
        result << mapped_category
      end
    end

    result
  end

  def build_tree(child_index, mapped_categories, categories)

    mapped_categories.each do |mapped_category|
      categories.each do |category|
        if mapped_category[:category_id] == category[:parent]
          sub_category = map_category(category)
          child_index << category[:name]
          mapped_category[:categories] << sub_category

          # recurse
          build_tree child_index, mapped_category[:categories], categories
        end
      end
    end

  end

  def map_category(category)
    {
        :category_id => category[:id],
        :child_index => [],
        :name => category[:name],
        :image => category[:image],
        :categories => []
    }
  end
end