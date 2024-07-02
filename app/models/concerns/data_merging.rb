require "active_support/concern"

module DataMerging
  extend ActiveSupport::Concern

  included do
    def merge_hotel(other)
      %w[destination latitude longitude].each do |key|
        if other[key].present?
          self[key] = other[key]
        end
      end

      # assume the longer info is more detailed and keep it
      %w[name address city country postal_code info].each do |key|
        if !self[key] || other[key]&.length&.>(self[key].length)
          self[key] = other[key]
        end
      end

      # try to deep_merge metadata
      h1 = metadata || {}
      h2 = other.metadata || {}
      new_metadata = h1.deep_merge(h2)
      new_metadata = nil if new_metadata.empty?
      self.metadata = new_metadata
    end
  end
end