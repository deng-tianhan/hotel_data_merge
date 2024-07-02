require 'rails_helper'

RSpec.describe HotelsController, type: :controller do
  before do
    allow(Hotel).to receive(:all).and_call_original
    allow(Hotel).to receive(:where).and_call_original
  end

  describe "GET /index" do
    it 'queries all Hotel' do
      get :index
      expect(Hotel).to have_received(:all)
    end
  end

  describe "GET /show" do
    let!(:hotel) { Hotel.create(identifier: '123') }

    it 'sets @hotel for display' do
      allow(Hotel).to receive(:for_show).and_call_original
      get :show, params: { id: hotel.id }
      expect(subject.instance_variable_get(:@hotel)).to eq(hotel)
    end
  end

  describe "GET /search" do
    it 'queries hotels' do
      get :search
      expect(Hotel).to have_received(:all)
    end

    context 'destination' do
      let(:params) { { destination: 123 } }

      it 'is filtered' do
        get :search, params: params
        expect(Hotel).to have_received(:where).with(destination: '123')
      end
    end

    context 'hotels' do
      let(:params) { { hotels: 'abc,def' } }

      it 'is filtered' do
        get :search, params: params
        expect(Hotel).to have_received(:where).with(identifier: %w[abc def])
      end
    end

    context 'both destination and hotels' do
      let(:params) { { destination: 123, hotels: 'abc,def' } }

      it 'can be filtered together' do
        query_builder = double(where: OpenStruct.new)
        allow(Hotel).to receive(:where).and_return(query_builder)
        get :search, params: params
        expect(Hotel).to have_received(:where).with(destination: '123')
        expect(query_builder).to have_received(:where).with(identifier: %w[abc def])
      end
    end

    it 'clear search' do
      get :search, params: { commit: 'clear' }
      expect(response).to redirect_to(hotels_url)
    end
  end

  describe "GET /api/search" do
    it 'uses for_api scope to eager load' do
      query_builder = double(for_api: [])
      allow(subject).to receive(:query_hotels) do
        subject.instance_variable_set(:@hotels, query_builder)
      end
      get :search_json
      expect(query_builder).to have_received(:for_api)
    end

    it 'render json' do
      get :search_json
      expect(response.header['Content-Type']).to include('application/json')
    end
  end

  describe 'POST /load_snapshot' do
    it 'populates DB using data from snapshot' do
      expect { suppress_log{ post :load_snapshot } }.to change{ Hotel.count }
    end
  end

  describe 'POST /load_url' do
    let(:url) { 'some_url' }
    let(:res) { double(body: 'some string') }

    it 'populates DB using data from url' do
      allow(Net::HTTP).to receive(:get_response).with(URI(url)).and_return(res)
      allow(res).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(subject).to receive(:create_hotels_from).with(anything)

      suppress_log{ post :load_url, params: { url: url} }

      expect(subject).to have_received(:create_hotels_from).with(res.body)
    end
  end

  describe 'POST /destroy_all' do
    before do
      hotel = Hotel.create(identifier: '123')
      Amenity.create(name: 'tv', hotel: hotel)
      Image.create(link: 'some link', imageable: hotel)
    end

    it 'destroy all' do
      expect { post :destroy_all }.to change{ Hotel.count }.to(0)
        .and change{ Amenity.count }.to(0)
        .and change{ Image.count }.to(0)
    end
  end

  describe '#create_hotels_from' do
    before do
      allow(DataCleaner).to receive(:process)
      allow(BatchQueryManager).to receive(:process)
    end

    it 'calls data cleaner and batch query manager' do
      subject.create_hotels_from(Snapshot.mixed_string)
      expect(DataCleaner).to have_received(:process).with(instance_of(Array))
      expect(BatchQueryManager).to have_received(:process).with(instance_of(Array))
    end
  end
end