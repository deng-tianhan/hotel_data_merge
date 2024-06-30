class Image < ApplicationRecord
  include DataCleaning

  belongs_to :imageable, polymorphic: true

  validates_presence_of :imageable, :link

  alias_attribute :url, :link
  alias_attribute :description, :caption

  SPECIAL_KEYS = ['images'].freeze

  class << self
    def build_from(attributes)
      [ data_cleaning(attributes)[SPECIAL_KEYS.first] ]
        .flatten.compact.uniq
        .map { |attrs| new(attrs) }
    end

    def process_nested(key, value, output)
      # {images:{x:[attrs]}} --> {images:[attrs.merge(category:x)]}
      if SPECIAL_KEYS.include?(key) && value.is_a?(Hash)
        output[SPECIAL_KEYS.first] ||= []
        output[SPECIAL_KEYS.first].concat(
          # value = [x,[attrs]]
          value.map do |k, v|
            # k,v = x,[attrs]
            v.map{ |attrs| attrs.merge('category' => k) }
          end.flatten
        )
        return true
      end
    end
  end
end
