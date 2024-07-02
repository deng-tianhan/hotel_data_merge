class HotelsController < ApplicationController
  require 'net/http'

  include HotelsHelper

  before_action :set_hotel, only: %i[ show ]
  before_action :query_hotels, only: %i[ search search_json ]

  SOURCE_URL = 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/'
  SOURCES = %w[acme patagonia paperflies]

  # GET /hotels or /hotels.json
  def index
    @hotels = Hotel.all
  end

  # GET /hotels/1 or /hotels/1.json
  def show
  end

  def search
    if params[:commit] == 'clear'
      return redirect_to hotels_url
    end

    @hotels = @hotels.all
    render :index
  end

  def search_json
    @hotels = @hotels.for_api
    render json: @hotels.map{ |x| prettify_hotel(x) }.as_json
  end

  def load_snapshot
    errors = create_hotels_from(Snapshot.mixed_string)
    load_response(errors)
  end

  def load_url
    uri = URI(params[:url])
    commit = params[:commit]

    if params[:url].blank? && SOURCES.include?(commit)
      uri = URI(SOURCE_URL + commit)
    end

    res = Net::HTTP.get_response(uri)
    string = res.body if res.is_a?(Net::HTTPSuccess)

    errors = create_hotels_from(string)
    load_response(errors)
  end

  def destroy_all
    # TRUNCATE TABLE not supported by sqlite
    # But sqlite does optimize DELETE when conditions are met
    # https://www.sqlite.org/lang_delete.html#the_truncate_optimization
    ActiveRecord::Base.connection.truncate_tables(
      Amenity.table_name,
      Hotel.table_name,
      Image.table_name
    )

    respond_to do |format|
      format.html { redirect_to hotels_url, notice: "All hotels successfully destroyed." }
      format.json { render :index, status: :deleted }
    end
  end

  def create_hotels_from(json_string)
    json_array = [JSON.parse(json_string)].flatten

    errors = []
    DataCleaner.process(json_array)
    BatchQueryManager.process(json_array)

    return errors
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_hotel
    @hotel = Hotel.for_show.find_by(id: params[:id])
    remove_broken_images
  end

  def query_hotels
    destination = params[:destination]
    identifiers = sanitize_identifiers(params[:hotels])

    query = Hotel
    query = query.where(destination: destination) if destination.present?
    query = query.where(identifier: identifiers) if identifiers.present?
    @hotels = query
  end

  def sanitize_identifiers(identifiers)
    return nil if identifiers.nil?
    begin
      identifiers.gsub(' ', '')
      identifiers = JSON.parse(identifiers)
    rescue JSON::ParserError => e
      identifiers = identifiers.split(',')
    end
  end

  def load_response(errors)
    respond_to do |format|
      if errors.blank?
        format.html { redirect_to hotels_url, notice: "Hotels successfully created." }
        format.json { render :index, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end
end
