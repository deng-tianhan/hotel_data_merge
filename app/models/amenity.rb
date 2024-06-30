class Amenity < ApplicationRecord
  include DataCleaning

  belongs_to :hotel

  validates_presence_of :hotel
  validates :name, presence: true, uniqueness: { scope: [:hotel_id, :category] }

  SPECIAL_KEYS = ['amenities','facilities'].freeze

  class << self
    def build_from(attributes)
      data = data_cleaning(attributes)
      SPECIAL_KEYS.map{ |key| data[key] }
        .flatten.compact.uniq
        .map { |x| x.is_a?(String) ? new(name:x) : new(x) }
    end

    def process_string(input)
      output = input.strip.titleize.downcase
      output = 'wifi' if output == 'wi fi'
      return output
    end

    def process_nested(key, value, output)
      # {amenities:{x:[text]}} --> {amenities:[{name:text,category:x}]}
      if SPECIAL_KEYS.include?(key) && value.is_a?(Hash)
        output[SPECIAL_KEYS.first] ||= []
        output[SPECIAL_KEYS.first].concat(
          value.map do |k, v|
            if v.is_a?(Array)
              v.map{ |name| { 'category' => k, 'name' => name } }
            else # v is a string: {facilities:['tv','wifi']}
              { 'name' => v }
            end
          end.flatten
        )
        return true
      end
    end
  end
end
