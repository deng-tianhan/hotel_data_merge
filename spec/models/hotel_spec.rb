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
  end
end
