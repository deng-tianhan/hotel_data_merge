class Amenity < ApplicationRecord
  belongs_to :hotel

  validates_presence_of :hotel
  validates :name, presence: true, uniqueness: { scope: :hotel_id }

  include DataCleaning

  SPECIAL_KEYS = ['amenities','facilities'].freeze

  def self.build_from(attributes)
    [ self.data_cleaning(attributes)[SPECIAL_KEYS.first] ]
      .flatten.compact.uniq
      .map { |x| new(name: x) }
  end

  def self.process_string(input)
    output = input.strip.underscore.gsub('_', ' ')
    output = 'wifi' if output == 'wi fi'
    return output
  end

  def self.process_nested_hash(key, value, output)
    return if SPECIAL_KEYS.exclude?(key)
    # special handling to drop nested key for amenities (paperflies format)
    # {amenities:{x:[1],y:[2]}} --> {amenities:[1,2]}
    output[SPECIAL_KEYS.first] ||= []
    output[SPECIAL_KEYS.first].concat(data_cleaning(value.values).flatten)
  end
end
