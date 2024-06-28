class Hotel < ApplicationRecord
  validates_presence_of :identifier

  def self.create_from(attributes)
    hotel = self.where(identifier: attributes[:identifier]).first_or_initialize
    hotel.update!(attributes)
    return hotel
  end
end
