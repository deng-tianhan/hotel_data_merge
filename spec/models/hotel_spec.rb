require 'rails_helper'

RSpec.describe Hotel, type: :model do
  let(:identifier) { 'Abc123' }

  describe 'validation' do
    subject { Hotel.new(identifier: identifier) }

    it 'should be valid' do
      expect(subject).to be_valid
    end

    context 'identifier is missing' do
      let(:identifier) { nil }
      it { expect(subject).to be_invalid }
    end

    context 'identifier is blank' do
      let(:identifier) { nil }
      it { expect(subject).to be_invalid }
    end
  end

  describe '#build_from' do
    let(:attributes) { { identifier: identifier } }
    let!(:hotel) { Hotel.create(identifier: identifier) }

    it 'does not persist' do
      expect{ hotel.build_from(attributes) }.to not_change{ Hotel.count }
    end

    context 'some fields are changed' do
      let(:new_description) { 'new text' }

      it 'changes accordingly' do
        hotel.build_from("info" => new_description)
        expect(hotel.changes).to eq("description" => [nil, new_description])
      end
    end

    it 'keeps alias attributes' do
      hotel.build_from({details: 'text', lat: 1.2}.as_json)
      expect(hotel).to have_attributes(info: 'text', latitude: 1.2)
    end

    context 'association' do
      it 'assigns new_amenities_attributes' do
        hotel.build_from({
          amenities: ['wifi'],
          facilities: { room: ['tv'] },
        }.as_json)
        expect(hotel.new_amenities_attributes).to eq([
          { hotel_id: hotel.id, name: "wifi", category: '' },
          { hotel_id: hotel.id, name: "tv", category: 'room' },
        ])
      end

      it 'assigns new_images_attributes' do
        hotel.build_from({
          images: { room: [{ link: 'link' }] }
        }.as_json)
        expect(hotel.new_images_attributes).to eq([{
          imageable_type: 'Hotel', imageable_id: hotel.id, category: 'room'
        }.merge("link" => "link")])
      end

      context 'from multiple sources' do
        let(:input1) { { images: { room: [{ link: 'link1' }] }}.as_json }
        let(:input2) { { images: { general: [{ link: 'link2' }] }}.as_json }

        it 'should be merged' do
          hotel.build_from(input1)
          hotel.build_from(input2)
          expect(hotel.new_images_attributes.count).to eq(2)
        end
      end
    end

    context 'metadata' do
      it 'converts unknown attribute to metadata' do
        hotel.build_from({info: 1, a:'b', c:'d'}.as_json)
        expect(hotel.metadata).to eq('a'=>'b', 'c'=>'d')
      end

      context 'from multiple sources' do
        let(:input1) { { a: [ {b: 1} ], c: 2 }.as_json }
        let(:input2) { { a: [ {b: 3, d: 4} ] }.as_json }

        it 'should be merged' do
          hotel.build_from(input1)
          hotel.build_from(input2)
          expect(hotel.metadata).to eq({a: [{b: 3, d: 4}], c: 2}.as_json)
        end
      end
    end
  end
end
