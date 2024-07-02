require 'rails_helper'

RSpec.describe DataCleaner do
  describe '.process' do
    def clean_data(input)
      DataCleaner.process([input.deep_dup].flatten).first
    end

    it 'converts keys and strip spaces' do
      expect(clean_data(' SomeKey ' => ' some value '))
        .to eq('some_key' => 'some value')
    end

    it 'converts nested keys and flattens the structure' do
      expect(clean_data(' location ' => { ' Inner Key ' => ' inner value ' }))
        .to eq('inner key' => 'inner value')
    end

    it 'does not change primary key' do
      expect(clean_data(id: 123)).to eq('identifier' => 123)
    end

    it 'keeps identifier and destination (acme format)' do
      input = Snapshot.acme_hotels.sample
      expect(clean_data(input))
        .to include('identifier' => input['Id'],
                    'destination_id' => input['DestinationId'])
    end

    it 'keeps identifier and destination (patagonia format)' do
      input = Snapshot.patagonia_hotels.sample
      expect(clean_data(input))
        .to include('identifier' => input['id'],
                    'destination' => input['destination'])
    end

    it 'keeps identifier and destination (paperflies format)' do
      input = Snapshot.paperflies_hotels.sample
      expect(clean_data(input))
        .to include('identifier' => input['hotel_id'],
                    'destination_id' => input['destination_id'])
    end
  end
end