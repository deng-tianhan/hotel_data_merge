class Hotel < ApplicationRecord
  has_many :amenities, dependent: :destroy

  validates :identifier, presence: true, uniqueness: true

  # special handling for alias
  alias_attribute :lat, :latitude
  alias_attribute :lng, :longitude
  alias_attribute :info, :description
  alias_attribute :details, :description
  alias_attribute :destination_id, :destination

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
    hotel_data = data.extract!(*column_names)
    amenities_data = data.extract!(*Amenity::SPECIAL_KEYS.clone)

    hotel = Hotel.where(identifier: hotel_data[UNIQUE_KEY]).first_or_initialize
    hotel.assign_attributes(
      **hotel_data,
      amenities: Amenity.build_from(amenities_data)
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
