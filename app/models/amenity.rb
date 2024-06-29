class Amenity < ApplicationRecord
  include DataCleaning

  belongs_to :hotel

  validates_presence_of :hotel
  validates :name, presence: true, uniqueness: { scope: :hotel_id }

  SPECIAL_KEYS = ['amenities','facilities'].freeze

  def eql?(other)
    if other.is_a?(Amenity)
      name.eql?(other.name)
    else
      super
    end
  end

  class << self
    def build_from(attributes)
      data = data_cleaning(attributes)
      SPECIAL_KEYS.map{ |key| data[key] }
        .flatten.compact.uniq
        .map { |x| new(name: x) }
    end

    def process_string(input)
      output = input.strip.titleize.downcase
      output = 'wifi' if output == 'wi fi'
      return output
    end

    def process_nested(key, value, output)
      # special handling to drop nested key for amenities (paperflies format)
      # {amenities:{x:[1],y:[2]}} --> {amenities:[1,2]}
      if SPECIAL_KEYS.include?(key) && value.is_a?(Hash)
        output[SPECIAL_KEYS.first] ||= []
        output[SPECIAL_KEYS.first].concat(data_cleaning(value.values).flatten)
        return true
      end
    end
  end
end
