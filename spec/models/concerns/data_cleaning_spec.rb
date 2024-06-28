require 'rails_helper'
require 'input_strings'

RSpec.describe DataCleaning do
  let(:temp_class) { Class.new { include DataCleaning } }

  describe '.data_cleaning' do
    it 'converts keys and strip spaces' do
      expect(temp_class.data_cleaning(' SomeKey ' => ' some value '))
        .to include('some_key' => 'some value')
    end

    it 'does not change primary key' do
      expect(temp_class.data_cleaning(id: 123).keys).not_to respond_to(:id)
    end

    it 'keeps identifier and destination (acme format)' do
      input = acme_hotels.sample
      expect(temp_class.data_cleaning(input))
        .to include('identifier' => input['Id'],
                    'destination_id' => input['DestinationId'])
    end

    it 'keeps identifier and destination (patagonia format)' do
      input = patagonia_hotels.sample
      expect(temp_class.data_cleaning(input))
        .to include('identifier' => input['id'],
                    'destination' => input['destination'])
    end

    it 'keeps identifier and destination (paperflies format)' do
      input = paperflies_hotels.sample
      expect(temp_class.data_cleaning(input))
        .to include('identifier' => input['hotel_id'],
                    'destination_id' => input['destination_id'])
    end
  end
end