class Hotel < ApplicationRecord
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

  attr_accessor :new_amenities_attributes, :new_images_attributes

  def build_from(data)
    hotel_data = data.extract!(*Hotel.column_names, *ALIASES.keys)
    amenities_data = data.extract!(*Amenity::SPECIAL_KEYS)
    images_data = data.extract!(*Image::SPECIAL_KEYS)

    hotel_data.merge!(metadata: data) if data.present?
    hotel_data.compact!

    if name.nil?
      assign_attributes(hotel_data)
    else
      # merge with in-memory new hotel to gain benefit from alias attributes
      merge_hotel(Hotel.new(hotel_data))
    end

    self.new_amenities_attributes = Amenity.attributes_from(amenities_data, id)
    self.new_images_attributes = Image.attributes_from(images_data, self)
  end

  scope :for_api, -> { eager_load(:amenities, :images) }

  class << self
    alias_method :for_batch_query, :for_api
    alias_method :for_show, :for_api
  end
end
