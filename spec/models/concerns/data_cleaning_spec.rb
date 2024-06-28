require 'rails_helper'
require 'input_strings'

RSpec.describe DataCleaning do
  let(:temp_class) { Class.new { include DataCleaning } }

  describe '.data_cleaning' do
    it 'converts keys and strip spaces' do
      expect(temp_class.data_cleaning(' SomeKey ' => ' some value ')).to include('some_key' => 'some value')
    end

    it 'converts nested keys and flattens the structure' do
      expect(temp_class.data_cleaning(' outerKey ' => { ' Inner Key ' => ' inner value ' })).to include('inner key' => 'inner value')
    end

    it 'does not change primary key' do
      expect(temp_class.data_cleaning(id: 123).keys).not_to respond_to(:id)
    end

    it 'keeps identifier (acme format)' do
      input = acme_hotels.sample
      expect(temp_class.data_cleaning(input)).to include('identifier' => input['Id'])
    end

    it 'keeps identifier (patagonia format)' do
      input = patagonia_hotels.sample
      expect(temp_class.data_cleaning(input)).to include('identifier' => input['id'])
    end

    it 'keeps identifier (paperflies format)' do
      input = paperflies_hotels.sample
      expect(temp_class.data_cleaning(input)).to include('identifier' => input['hotel_id'])
    end
  end
end