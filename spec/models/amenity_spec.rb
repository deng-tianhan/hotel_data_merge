require 'rails_helper'

RSpec.describe Amenity, type: :model do
  describe '.data_cleaning' do
    it { expect(Amenity.data_cleaning(' Tv ')).to contain_exactly('tv') }
    it { expect(Amenity.data_cleaning('BusinessCenter')).to contain_exactly('business center') }
    it { expect(Amenity.data_cleaning('WiFi')).to contain_exactly('wifi') }
    it { expect(Amenity.data_cleaning('Coffee machine')).to contain_exactly('coffee machine') }
  end
end
