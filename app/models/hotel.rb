class Hotel < ApplicationRecord
  has_many :amenities, dependent: :destroy

  validates :identifier, presence: true, uniqueness: true

  ALIASES = {
    'lat'=>:latitude, 'lng'=>:longitude, 'info'=>:description,
    'details'=>:description, 'destination_id'=>:destination
  }.freeze
  ALIASES.each { |k, v| alias_attribute(k, v) }

  include DataCleaning

  UNIQUE_KEY = 'identifier'.freeze
  SPECIAL_KEYS = ['location'].freeze

  def self.create_from(attributes)
    hotel = build_from(attributes)
    hotel.save!
    return hotel
  end

  def self.build_from(attributes)
    data = data_cleaning(attributes)
    hotel_data = data.extract!(*column_names, *ALIASES.keys)
    amenities_data = data.extract!(*Amenity::SPECIAL_KEYS.clone)

    hotel = Hotel.where(identifier: hotel_data[UNIQUE_KEY]).first_or_initialize
    hotel.assign_attributes(
      **hotel_data,
      amenities: Amenity.build_from(amenities_data),
      metadata: data
    )
    return hotel
  end

  def self.process_nested_hash(key, value, output)
    return if SPECIAL_KEYS.exclude?(key)
    # special handling for nested attributes (paperflies format)
    # {location:{country:'SG'}} --> {country:'SG'}
    output.merge!(data_cleaning(value))
  end
end
