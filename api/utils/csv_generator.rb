# require 'csv'
require 'json'

class CsvGenerator

  def self.json_to_csv(json)

    parsed_json = JSON.parse(json)
    header_row = []
    data_rows = []
    rows = []

    parsed_json.each do |item|
      current_row = []
      parse_item(header_row, current_row, item, nil)
      rows << current_row
    end

    header_row.sort!

    extract_rows header_row, data_rows, rows

    header_row.join(',') + "\r\n" + data_rows.join("\r\n")

  end

  def self.parse_item(header_row, current_row, item, item_parent)

    item.each do |key, value|
      if value.is_a? Hash
         parse_item header_row, current_row, value, key.to_s
      elsif value.is_a? Array
        value.each do |arr_item|
           parse_item header_row, current_row, arr_item, key.to_s
        end
      else
        current_parent = item_parent != nil ? item_parent + '.' + key.to_s : key.to_s
        current_row << current_parent + '|' + value.to_s

        unless header_row.include? current_parent
          header_row << current_parent
        end
      end
    end
  end

  def self.extract_rows(header_row, data_rows, rows)
    header_len = header_row.length - 1

    rows.each do |row|
      arr = Array.new(header_len)
      row.each do |item|
        pair = item.to_s.split('|')
        header = pair[0]
        value = pair[1]

        index = header_row.index(header)

        arr[index] = "\"#{value}\""
      end
      data_rows << arr.join(',')
    end
  end

end