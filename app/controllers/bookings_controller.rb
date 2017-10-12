class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :update, :destroy]

  # GET /bookings
  def index
    @bookings = Booking.all

    render json:  { bookings: @bookings }
  end

  # GET /bookings/1
  def show
    render json: { booking: @booking }
  end

  # POST /bookings
  def create
    rental = Rental.find(params[:booking][:rental])
    @booking = rental.bookings.new(booking_params)

    if @booking.save
      render json: { booking: @booking }, status: :created, location: @booking
    else
      render json: {errors: @booking.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bookings/1
  def update
    if @booking.update(booking_params)
      render json: @booking
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bookings/1
  def destroy
    @booking.destroy
  end

  # GET /bookings/rental_id/get_price
  def get_price
    render json: { price: @rental.calculate_price(start_at, end_at)}, status: 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def booking_params
      params.require(:booking).permit(:start_at, :end_at, :client_email, :price, :rental_id)
    end
end
