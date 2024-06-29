class Hotel < ApplicationRecord
  include DataCleaning
  include DataMerging

  has_many :amenities, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  validates :identifier, presence: true, uniqueness: true

  ALIASES = {
    'lat'=>:latitude, 'lng'=>:longitude, 'info'=>:description,
    'details'=>:description, 'destination_id'=>:destination
  }.freeze
  ALIASES.each { |k, v| alias_attribute(k, v) }

  UNIQUE_KEY = 'identifier'.freeze
  SPECIAL_KEYS = ['location'].freeze

  class << self
    def create_from(attributes)
      hotel = build_from(attributes)
      hotel.save!
      return hotel
    end

    def build_from(attributes)
      data = data_cleaning(attributes)
      hotel_data = data.extract!(*column_names, *ALIASES.keys)
      amenities_data = data.extract!(*Amenity::SPECIAL_KEYS)
      images_data = data.extract!(*Image::SPECIAL_KEYS)

      hotel = Hotel.where(identifier: hotel_data[UNIQUE_KEY]).first_or_initialize
      hotel.assign_attributes(
        **(hotel.persisted? ? hotel.merge_hotel(new(hotel_data)) : hotel_data),
        amenities: hotel.merge_amenities(Amenity.build_from(amenities_data)),
        images: hotel.merge_images(Image.build_from(images_data)),
        metadata: data
      )
      return hotel
    end

    alias_method :original_transform_key, :transform_key
    alias_method :original_data_cleaning, :data_cleaning

    def transform_key(key)
      key = original_transform_key(key)
      # remove prefix (paperflies format)
      key = key[6..-1] if key.starts_with?('hotel_')
      return key
    end

    def data_cleaning(input)
      output = original_data_cleaning(input)
      output[UNIQUE_KEY] ||= output.delete('id')
      return output
    end

    def process_nested(key, value, output)
      # special handling for nested attributes (paperflies format)
      # {location:{country:'SG'}} --> {country:'SG'}
      if SPECIAL_KEYS.include?(key) && value.is_a?(Hash)
        output.merge!(data_cleaning(value))
        return true
      end
    end
  end
end
