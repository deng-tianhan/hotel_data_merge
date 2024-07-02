class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  validates_presence_of :imageable, :link

  alias_attribute :url, :link
  alias_attribute :description, :caption

  SPECIAL_KEYS = ['images'].freeze

  class << self
    # {images:{category:[attrs]}}
    def attributes_from(data, imageable)
      output = []
      data.values.each do |hash|
        hash.each do |category, array|
          array.each do |attrs|
            output.push(
              attrs.merge(
                category: category,
                imageable_type: imageable.class.name,
                imageable_id: imageable.id
              )
            )
          end
        end
      end
      return output.uniq
    end
  end
end
