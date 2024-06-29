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

  describe '.create_from' do
    let(:attributes) { { identifier: identifier } }

    it 'creates new hotel' do
      expect{ Hotel.create_from(attributes) }.to change{ Hotel.count }.by(1)
    end

    it 'returns the hotel' do
      expect(Hotel.create_from(attributes)).to be_an_instance_of(Hotel)
    end

    context 'hotel already exists' do
      let!(:existing_hotel) { Hotel.create(identifier: identifier) }

      it 'does not create a duplicate' do
        expect{ Hotel.create_from(attributes) }.not_to change{ Hotel.count }
      end

      context 'some fields are changed' do
        let(:new_description) { 'new text' }
        let(:attributes) { { identifier: identifier, description: new_description } }

        it 'updates the existing hotel' do
          expect{ Hotel.create_from(attributes) }.to change{ Hotel.last.description }.from(nil).to(new_description)
        end
      end
    end

    context 'save data' do
      before { allow(Hotel).to receive(:new).and_return(subject) }
      let(:attributes) { { identifier: identifier, amenities: ['wifi'] } }

      it 'persists hotel and amenities' do
        expect{ Hotel.create_from(attributes) }
          .to change{ Hotel.count }.by(1)
          .and change{ Amenity.count }.by(1)
      end

      it 'does not create duplicate' do
        Hotel.create_from(attributes)
        expect{ Hotel.create_from(attributes) }
          .to not_change{ Hotel.count }
          .and not_change{ Amenity.count }
      end

      it 'converts unknown attribute to metadata' do
        Hotel.create_from(attributes.merge(a:'b', c:'d'))
        expect(Hotel.last.metadata).to eq('a'=>'b', 'c'=>'d')
      end

      context 'hotel raises error' do
        before { allow(Hotel).to receive(:new).and_raise('hotel') }

        it 'does not persist amenities' do
          expect{ Hotel.create_from(attributes) }
            .to raise_error('hotel')
            .and not_change{ Amenity.count }
        end
      end

      context 'amenities raises error' do
        before { allow(Amenity).to receive(:new).and_raise('amenities') }

        it 'does not persists hotel' do
          expect{ Hotel.create_from(attributes) }
            .to raise_error('amenities')
            .and not_change{ Hotel.count }
        end
      end
    end
  end

  describe '.data_cleaning' do
    it 'converts nested keys and flattens the structure' do
      expect(Hotel.data_cleaning(' location ' => { ' Inner Key ' => ' inner value ' }))
        .to include('inner key' => 'inner value')
    end
  end
end
