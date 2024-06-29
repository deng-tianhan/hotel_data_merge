require 'rails_helper'
require 'input_strings'

RSpec.describe "DataMerging" do
  let(:identifier) { '1A2b3C' }

  context 'merge fields' do
    let(:attr1) { { identifier: identifier, description: 'more detailed text' } }
    let(:attr2) { { identifier: identifier, description: 'short text' } }

    it 'keeps the longer description' do
      Hotel.create_from(attr1)
      Hotel.create_from(attr2)
      expect(Hotel.last).to have_attributes(attr1)
    end
  end

  context 'merge amenities' do
    let(:attr1) { { identifier: identifier, facilities:['tv','wifi'] } }
    let(:attr2) { { identifier: identifier } }
    let(:attr3) { { identifier: identifier, amenities:{outside:['pool'],inside:['tv']} } }

    it 'keeps amenities by unique name' do
      Hotel.create_from(attr1)
      expect(Hotel.last.amenities.map(&:name)).to eq(['tv','wifi'])
      Hotel.create_from(attr2)
      expect(Hotel.last.amenities.map(&:name)).to eq(['tv','wifi'])
      Hotel.create_from(attr3)
      expect(Hotel.last.amenities.map(&:name)).to eq(['tv','wifi','pool'])
    end
  end

  context 'merge images' do
    let(:attr1) { { identifier: identifier, images:{room:[{link:'a'},{link:'b'}]} } }
    let(:attr2) { { identifier: identifier } }
    let(:attr3) { { identifier: identifier, images:{site:[{url:'a'},{url:'c'}]} } }

    it 'keeps images by unique url' do
      Hotel.create_from(attr1)
      expect(Hotel.last.images.count).to eq(2)
      Hotel.create_from(attr2)
      expect(Hotel.last.images.count).to eq(2)
      Hotel.create_from(attr3)
      expect(Hotel.last.images.count).to eq(3)
    end
  end
end