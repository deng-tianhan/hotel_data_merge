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
    key.ends_with?('_id') || key.ends_with?('s') || key == 'destination'
  end

  def self.create_from(attributes)
    attributes = data_cleaning(attributes)
    hotel = Hotel.where(identifier: attributes['identifier']).first_or_initialize
    hotel.update!(attributes)
    return hotel
  end
end
