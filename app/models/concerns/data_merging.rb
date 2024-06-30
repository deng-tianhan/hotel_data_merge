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
      delete_old = []
      delete_new = []
      old_amenities = amenities.to_a
      old_amenities.each do |a|
        new_amenities.each do |b|
          next if a.name.gsub(' ', '') != b.name.gsub(' ', '')
          if a.category.blank?
            delete_old.push(a)
          elsif b.category.blank?
            delete_new.push(b)
          else
            # same name different category, keep both
          end
        end
      end
      delete_old.each { |x| old_amenities.delete(x) }
      delete_new.each { |x| new_amenities.delete(x) }
      old_amenities.concat(new_amenities).uniq{ |x| [x.name,x.category] }
    end

    def merge_images(new_images)
      images.to_a.concat(new_images).uniq(&:link)
    end
  end
end