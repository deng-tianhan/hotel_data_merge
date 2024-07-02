require 'rails_helper'

RSpec.describe DataMerging do
  let(:identifier) { '1A2b3C' }

  context 'merge fields' do
    let(:attr1) { { identifier: identifier, description: 'more detailed text' } }
    let(:attr2) { { identifier: identifier, description: 'short text' } }
    let(:hotel) { Hotel.new(attr1) }

    it 'keeps the longer description' do
      hotel.merge_hotel(Hotel.new(attr2))
      expect(hotel).to have_attributes(attr1)
    end

    it 'replace destination, unless empty' do
      hotel.merge_hotel(Hotel.new(**attr2, destination: 1234))
      expect(hotel.destination).to eq(1234)

      hotel.merge_hotel(Hotel.new(**attr2, destination: nil))
      expect(hotel.destination).to eq(1234)
    end
  end
end