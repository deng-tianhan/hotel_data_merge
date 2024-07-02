class BatchQueryManager
  BATCH_SIZE = 1000

  attr_accessor :data, :identifiers, :amenity_attrs, :image_attrs

  def self.process(data)
    instance = new(data)
    instance.insert_hotels
    instance.update_hotels
    instance.upsert_amenities
    instance.upsert_images
  end

  def initialize(data)
    Rails.logger = Logger.new(STDOUT)
    self.data = data
    self.identifiers = data.map { |hash| hash[Hotel::UNIQUE_KEY] }.uniq
    self.amenity_attrs = []
    self.image_attrs = []
  end

  def insert_hotels
    old_identifiers = Hotel.where(identifier: identifiers).pluck(:identifier)
    new_identifiers = identifiers - old_identifiers
    new_identifiers.in_groups_of(BATCH_SIZE, false) do |group|
      Hotel.insert_all!(
        group.map{ |x| { identifier: x } },
        returning: false, record_timestamps: true
      )
    end
  end

  # use upsert_all to update multiple hotels in a single query
  def update_hotels
    hotels = Hotel.for_batch_query.where(identifier: identifiers)
    hotels.find_in_batches(batch_size: BATCH_SIZE) do |batch|
      hotel_attrs = []
      batch.each do |hotel|
        matched_data, data = self.data.partition do |hash|
          hash[Hotel::UNIQUE_KEY] == hotel.identifier
        end
        matched_data.each { |hash| hotel.build_from(hash) }

        hotel_attrs.push(hotel.attributes)
        amenity_attrs.concat(hotel.new_amenities_attributes)
        image_attrs.concat(hotel.new_images_attributes)
      end
      Rails.logger.debug "#{batch.count} Hotels"
      Hotel.upsert_all(hotel_attrs, returning: false, record_timestamps: true)
    end
  end

  def upsert_amenities
    Rails.logger.debug "#{amenity_attrs.count} Amenities to upsert"
    amenity_attrs.in_groups_of(BATCH_SIZE, false) do |group|
      Amenity.upsert_all(
        group,
        returning: false, record_timestamps: true,
        unique_by: %i[ hotel_id category name ]
      )
    end
  end

  def upsert_images
    Rails.logger.debug "#{image_attrs.count} Images to upsert"
    image_attrs.in_groups_of(BATCH_SIZE, false) do |group|
      Image.upsert_all(
        group,
        returning: false, record_timestamps: true,
        unique_by: %i[ imageable_type imageable_id link ]
      )
    end
  end
end