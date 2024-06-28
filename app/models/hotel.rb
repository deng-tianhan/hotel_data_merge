class Hotel < ApplicationRecord
  validates_presence_of :identifier

  # special handling for alias (patagonia format)
  alias_attribute :lat, :latitude
  alias_attribute :lng, :longitude
  alias_attribute :info, :description

  def self.data_cleaning(input)
    output = {}

    input.each do |key, value|
      key = key.to_s.strip.underscore

      # remove prefix (paperflies format)
      key = key[6..-1] if key.starts_with?('hotel_')

      # skip belongs_to and has_many associations
      next if key.ends_with?('_id') || key.ends_with?('s') || key == 'destination'

      # special handling for nested attributes (paperflies format)
      if value.is_a?(Hash)
        output.merge!(data_cleaning(value))
        next
      end

      output[key] = value.is_a?(String) ? value.strip : value
    end

    # handle identifier and do not touch primary key
    output['identifier'] ||= output.delete('id')

    return output
  end

  def self.create_from(attributes)
    attributes = data_cleaning(attributes)
    hotel = Hotel.where(identifier: attributes['identifier']).first_or_initialize
    hotel.update!(attributes)
    return hotel
  end
end
