require 'rails_helper'

RSpec.describe Amenity, type: :model do
  describe '.build_from' do
    def process(*args)
      Amenity.build_from(amenities: args).map(&:name)
    end

    it { expect(process(nil)).to eq([]) }
    it { expect(process([' Tv '])).to contain_exactly('tv') }
    it { expect(process('BusinessCenter')).to contain_exactly('business center') }
    it { expect(process('WiFi')).to contain_exactly('wifi') }
    it { expect(process('Coffee machine')).to contain_exactly('coffee machine') }

    it 'removes duplicates' do
      input = {
        amenities: { "general"=>["pool","wifi"] },
        facilities: { "general"=>["wifi"] }
      }
      output = Amenity.build_from(input)

      expect(output).to be_an_instance_of(Array)
      expect(output.length).to eq(2)
      expect(output.map(&:attributes).map(&:compact))
        .to eq(
          [
            { "category"=>"general", "name"=>"pool" },
            { "category"=>"general", "name"=>"wifi" },
          ]
        )
    end
  end

  describe '.data_cleaning' do
    it 'retains nested key as category' do
      input = {
        amenities: { "general"=>["pool"] },
        facilities: { "room"=>["tv"] }
      }
      expect(Amenity.data_cleaning(input)).to eq(
        "amenities" => [
          { "category"=>"general", "name"=>"pool" },
          { "category"=>"room", "name"=>"tv" }
        ]
      )
    end

    context 'no nested key' do
      let(:input) { { facilities:["tv","wifi"] } }

      it 'leaves category empty' do
        expect(Amenity.data_cleaning(input)).to eq("facilities"=>["tv","wifi"])
      end
    end
  end
end
