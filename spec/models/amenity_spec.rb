require 'rails_helper'

RSpec.describe Amenity, type: :model do
  describe '.clean_array' do
    def process(*args)
      Amenity.clean_array(amenities: args)
    end

    it { expect(process(nil)).to eq([]) }
    it { expect(process([' Tv '])).to contain_exactly('tv') }
    it { expect(process('BusinessCenter')).to contain_exactly('business center') }
    it { expect(process('WiFi')).to contain_exactly('wifi') }
    it { expect(process('Coffee machine')).to contain_exactly('coffee machine') }
  end

  describe '.data_cleaning' do
    it 'merges amenities by dropping nested key' do
      input = {
        amenities: { "general"=>["pool"] },
        facilities: { "room"=>["tv"] }
      }
      expect(Amenity.data_cleaning(input)).to include('amenities' => ['pool', 'tv'])
    end
  end
end
