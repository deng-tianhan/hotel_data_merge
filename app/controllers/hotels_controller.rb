class HotelsController < ApplicationController
  before_action :set_hotel, only: %i[ show ]

  # GET /hotels or /hotels.json
  def index
    @hotels = Hotel.all
  end

  # GET /hotels/1 or /hotels/1.json
  def show
  end

  # GET /hotels/new
  def new
    @hotel = Hotel.new
  end

  # GET /hotels/1/edit
  def edit
  end

  def load_snapshot
    require '.\spec\input_strings.rb'
    errors = create_hotels_from(mixed_string)

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

  def destroy_all
    Hotel.all.map(&:destroy!)

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
    end

    # Only allow a list of trusted parameters through.
    def hotel_params
      params.require(:hotel).permit(:index)
    end
end
