class Hotel < ApplicationRecord
  has_many :amenities

  validates_presence_of :identifier

  # special handling for alias
  alias_attribute :lat, :latitude
  alias_attribute :lng, :longitude
  alias_attribute :info, :description
  alias_attribute :details, :description

  include DataCleaning

  def self.skip_key?(key)
    # skip associations and unfinished logic
    key.ends_with?('_id') || key == 'destination' || key == 'images'
  end

  def self.create_from(attributes)
    attributes.transform_keys!{ |key| transform_key(key) }
    hotel_data = data_cleaning(attributes)
    amenities_data = hotel_data.extract!('amenities', 'facilities')

    hotel = Hotel.where(identifier: hotel_data['identifier']).first_or_initialize
    hotel.update!(hotel_data)
    hotel.create_amenities_from(Amenity.clean_array(amenities_data))

    return hotel
  end

  def create_amenities_from(list)
    amenities_found = amenities.where(name: list).pluck(:name)

    list_to_delete = amenities_found - list
    if list_to_delete.present?
      amenities.where(name: list_to_delete).delete_all
    end

    list_to_create = list - amenities_found
    list_to_create.each do |name|
      amenities.create!(name: name, hotel: self)
    end
  end

  # special handling for paperflies format
  def booking_conditions=(array)
    self.details = array.unshift(details).join(' ')
  end
end
