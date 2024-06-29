require 'rails_helper'
require 'input_strings'

RSpec.describe HotelsController do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end

  describe '#create_hotels_from' do
    it { expect(subject.create_hotels_from(mixed_string)).to be }
  end
end