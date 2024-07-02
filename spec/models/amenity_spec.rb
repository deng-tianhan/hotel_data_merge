require 'rails_helper'

RSpec.describe Amenity, type: :model do
  describe '.attributes_from' do
    let(:hotel_id) { 123 }

    def process(*args)
      Amenity.attributes_from({amenities: args.compact}, hotel_id)
        .map{ |attrs| attrs[:name] }
    end

    it { expect(process(nil)).to eq([]) }
    it { expect(process(' Tv ', 'tv')).to contain_exactly('tv') }
    it { expect(process('BusinessCenter')).to contain_exactly('business center') }
    it { expect(process('WiFi')).to contain_exactly('wifi') }
    it { expect(process('Coffee machine')).to contain_exactly('coffee machine') }

    it 'removes duplicates' do
      input = {
        amenities: { "general"=>["pool","wifi"] },
        facilities: { "general"=>["wifi"] }
      }
      output = Amenity.attributes_from(input, hotel_id)

      expect(output).to be_an_instance_of(Array)
      expect(output.length).to eq(2)
      expect(output).to eq([
        { category: 'general', name: 'pool', hotel_id: hotel_id },
        { category: 'general', name: 'wifi', hotel_id: hotel_id },
      ])
    end

    it 'retains nested key as category' do
      input = {
        amenities: { "general"=>["pool"] },
        facilities: { "general"=>["wifi"] }
      }
      expect(Amenity.attributes_from(input, hotel_id)).to eq([
        { category: 'general', name: 'pool', hotel_id: hotel_id },
        { category: 'general', name: 'wifi', hotel_id: hotel_id },
      ])
    end

    context 'no nested key' do
      let(:input) { { facilities:["tv","wifi"] } }

      it 'keeps category nil for upsert' do
        expect(Amenity.attributes_from(input, hotel_id)).to eq([
          { category: nil, name: 'tv', hotel_id: hotel_id },
          { category: nil, name: 'wifi', hotel_id: hotel_id },
        ])
      end
    end
  end
end
