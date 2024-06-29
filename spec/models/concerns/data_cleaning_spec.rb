require 'rails_helper'
require 'input_strings'

RSpec.describe DataCleaning do
  let(:temp_class) { Class.new { include DataCleaning } }

  describe '.data_cleaning' do
    it 'converts keys and strip spaces' do
      expect(temp_class.data_cleaning(' SomeKey ' => ' some value '))
        .to include('some_key' => 'some value')
    end
  end
end