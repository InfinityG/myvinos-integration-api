module MyVinos
  module Models
    class QueueItem
      include MongoMapper::Document

      key :order_id, String, :required => true
      key :checkout_id, String, :required => true
      key :status, String, :required => true

      timestamps!

    end
  end
end