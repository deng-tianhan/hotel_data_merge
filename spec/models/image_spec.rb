require 'rails_helper'
require 'input_strings'

RSpec.describe Image, type: :model do
  describe '.build_from' do
    def size_of(image_attributes)
      image_attributes['images'].values.sum{ |array| array.count }
    end

    it 'removes duplicates' do
      attr = image_attributes
      attr_with_duplicate = attr.transform_values do |hash|
        hash.transform_values { |array| array * 2 }
      end
      output = Image.build_from(attr_with_duplicate)

      original_size = size_of(attr)
      duplicate_size = size_of(attr_with_duplicate)

      expect(duplicate_size).to eq(original_size * 2)
      expect(output.count).to eq(original_size)
    end
  end

  describe '.data_cleaning' do
    it 'converts image attributes' do
      Image.data_cleaning(image_attributes)['images'].each do |attrs|
        expect(attrs.keys).to eq(
          ['link','caption','category']
        ).or eq(
          ['url','description','category']
        )
      end
    end
  end
end
