require 'rails_helper'

RSpec.describe Amenity, type: :model do
  describe '.clean_array' do
    it { expect(Amenity.clean_array(nil)).to eq([]) }
    it { expect(Amenity.clean_array(' Tv ')).to contain_exactly('tv') }
    it { expect(Amenity.clean_array('BusinessCenter')).to contain_exactly('business center') }
    it { expect(Amenity.clean_array('WiFi')).to contain_exactly('wifi') }
    it { expect(Amenity.clean_array('Coffee machine')).to contain_exactly('coffee machine') }
  end
end
