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

    render :index
  end

  def search_json
    @hotels = @hotels.eager_load(:amenities, :images).all
    render json: @hotels.map{ |x| prettify_hotel(x) }.as_json
  end

  def load_snapshot
    require '.\spec\input_strings'
    errors = create_hotels_from(mixed_string)
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
    Hotel.delete_all
    Amenity.delete_all
    Image.delete_all

    respond_to do |format|
      format.html { redirect_to hotels_url, notice: "All hotels successfully destroyed." }
      format.json { render :index, status: :deleted }
    end
  end

  def create_hotels_from(json_string)
    json_array = JSON.parse(json_string)

    errors = []
    json_array.each do |attributes|
      hotel = Hotel.create_from(attributes)
      errors.push(hotel.errors) if hotel.errors.present?
    end

    return errors
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_hotel
    @hotel = Hotel.find_by(id: params[:id]) || Hotel.find_by(identifier: params[:id])
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
