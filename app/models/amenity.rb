class Amenity < ApplicationRecord
  belongs_to :hotel

  def self.data_cleaning(input)
    output = []

    case input
    when Array
      output = input.map { |x| data_cleaning(x) }
    when Hash
      # flatten nested entries (paperflies format)
      input.each { |_, v| output.push(data_cleaning(x)) }
    else
      clean_data = input.strip.underscore.gsub('_', ' ')
      clean_data = 'wifi' if clean_data == 'wi fi'
      output.push(clean_data)
    end

    return output
  end
end
