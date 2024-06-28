class Amenity < ApplicationRecord
  belongs_to :hotel

  include DataCleaning

  def self.clean_array(input)
    [ self.data_cleaning(input) ].flatten.compact
  end

  def self.process_string(input)
    output = input.strip.underscore.gsub('_', ' ')
    output = 'wifi' if output == 'wi fi'
    return output
  end
end
