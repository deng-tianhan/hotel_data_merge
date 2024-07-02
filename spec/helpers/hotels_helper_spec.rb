require 'rails_helper'

RSpec.describe HotelsHelper do
  let(:hotel) { Hotel.create(id: 3, identifier: 'x') }
  before { @hotel = hotel }

  describe '#prettify_hotel' do
    let(:json) { JSON.parse(Snapshot.response_string)[0] }

    it 'should be identical' do
      HotelsController.new.create_hotels_from(Snapshot.response_string)
      @hotel = Hotel.last
      output = prettify_hotel
      expect(output.except('amenities')).to eq(json.except('amenities'))

      # amenities may be in different order due to sorting
      expect(output['amenities'].keys).to eq(json['amenities'].keys)
      output['amenities'].each do |category, values|
        expect(values).to contain_exactly(*json['amenities'][category])
      end
    end

    context 'postal code not in address string' do
      let(:hotel) do
        Hotel.create(identifier:'x',address:'home',postal_code:'0123')
      end

      it 'should be appended' do
        expect(prettify_hotel['location']).to eq("address"=>"home, 0123")
      end
    end
  end

  describe '#prettify_amenities' do
    let!(:a1) { hotel.amenities.create(category:'general',name:'indoor pool') }
    let!(:a2) { hotel.amenities.create(category:'room',name:'tv') }
    let!(:a3) { hotel.amenities.create(category:'room',name:'aircon') }
    let(:output) { prettify_amenities }

    it 'group by category' do
      expect(output['general']).to eq(['indoor pool'])
      expect(output['room']).to contain_exactly('tv','aircon')
    end

    context 'ungategorised name found under another category' do
      let!(:a4) { hotel.amenities.create(name:'pool') }

      it 'should be ignored' do
        expect(output['general']).to eq(['indoor pool'])
        expect(output['room']).to contain_exactly('tv','aircon')
      end
    end

    context 'ungategorised name not found under other category' do
      let!(:a4) { hotel.amenities.create(name:'wifi') }

      it 'should be placed under general' do
        expect(output['general']).to contain_exactly('indoor pool','wifi')
        expect(output['room']).to contain_exactly('tv','aircon')
      end
    end
  end

  describe '#sort_images' do
    it { expect(sort_images).to eq([]) }

    context 'has images' do
      let!(:image1) { hotel.images.create(caption:'a',category:'z',link:'1') }
      let!(:image2) { hotel.images.create(caption:'b',category:'x',link:'2') }
      let!(:image3) { hotel.images.create(caption:'c',category:'z',link:'3') }

      it 'sort by category, followed by caption' do
        expect(sort_images).to eq([image2, image1, image3])
      end

      it 'unifies category' do
        # category is the nested key and can be different based on source
        # assuming caption is more important than the category
        image2.update!(caption: 'c')
        expect(sort_images.map(&:category)).to eq(%w[z z z])
      end
    end
  end

  describe "navigation" do
    it { expect(prev_hotel_id).to be_nil }
    it { expect(next_hotel_id).to be_nil }

    context 'exists hotel with smaller id' do
      let!(:other_hotel) { Hotel.create(id: 1, identifier: 'a') }
      it { expect(prev_hotel_id).to eq(1) }
    end

    context 'exists hotel with bigger id' do
      let!(:other_hotel) { Hotel.create(id: 10, identifier: 'z') }
      it { expect(next_hotel_id).to eq(10) }
    end
  end
end