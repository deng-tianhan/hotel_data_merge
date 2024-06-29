require "active_support/concern"

module DataMerging
  extend ActiveSupport::Concern

  included do
    COLUMNS_TO_REPLACE = %w[
      name destination latitude longitude
      address city country postal_code
    ].freeze

    def merge_hotel(other)
      output = {}
      COLUMNS_TO_REPLACE.each { |key| output[key] = self[key] || other[key] }

      # assume the longer info is more detailed and keep it
      if !info || (other.info && other.info.length > info.length)
        output[:info] = other.info
      end

      # try to deep_merge metadata
      h1 = metadata || {}
      h2 = other.metadata || {}
      new_metadata = h1.deep_merge(h2, &:+)
      new_metadata = nil if new_metadata.empty?
      output[:metadata] = new_metadata

      return output
    end

    def merge_amenities(new_amenities)
      amenities.to_a.concat(new_amenities).uniq
    end

    def merge_images(new_images)
      images.to_a.concat(new_images).uniq
    end
  end
end