class Amenity < ApplicationRecord
  belongs_to :hotel

  validates_presence_of :hotel, :name

  SPECIAL_KEYS = ['amenities','facilities'].freeze

  class << self
    # accpets 2 data formats:
    # {amenities:{general:['pool'],room:['tv']}}
    # {facilities:['tv','wifi']}
    def attributes_from(data, hotel_id)
      output = []
      data.values.each do |value|
        case value
        when Hash # {general:['pool'],room:['tv']}
          value.each do |k, v|
            v.each do |name|
              output.push(
                hotel_id: hotel_id,
                category: k.strip.underscore,
                name: process_string(name)
              )
            end
          end
        when Array # ['tv','wifi']
          value.each do |name|
            output.push(
              hotel_id: hotel_id,
              category: '', # required for upsert
              name: process_string(name)
            )
          end
        end
      end

      return output.uniq
    end

    def process_string(input)
      output = input.strip.titleize.downcase
      output = 'wifi' if output == 'wi fi'
      return output
    end
  end
end
