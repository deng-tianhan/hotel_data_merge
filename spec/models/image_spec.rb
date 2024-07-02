require 'rails_helper'

RSpec.describe Image, type: :model do
  describe '.attributes_from' do
    let(:hotel) { Hotel.new(id: 12345) }

    def size_of(image_attributes)
      image_attributes['images'].values.sum{ |array| array.count }
    end

    it 'removes duplicates' do
      attr = Snapshot.image_attributes
      attr_with_duplicate = attr.transform_values do |hash|
        hash.transform_values { |array| array * 2 }
      end
      output = Image.attributes_from(attr_with_duplicate, hotel)

      original_size = size_of(attr)
      duplicate_size = size_of(attr_with_duplicate)

      expect(duplicate_size).to eq(original_size * 2)
      expect(output.count).to eq(original_size)
    end

    it 'converts image attributes' do
      attrs = Image.attributes_from(Snapshot.image_attributes, hotel)
      attrs.each do |attrs|
        expect(attrs.extract!(:imageable_type, :imageable_id)).to eq(
          imageable_type: 'Hotel',
          imageable_id: hotel.id
        )
        expect(attrs.keys.map(&:to_s)).to eq(
          ['link','caption','category']
        ).or eq(
          ['url','description','category']
        )
      end
    end
  end
end
