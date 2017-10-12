class RentalsController < ApplicationController
  before_action :set_rental, only: [:show, :update, :destroy]

  # GET /rentals
  def index
    @rentals = Rental.all
    render json: { rentals: @rentals }
  end

  # GET /rentals/1
  def show
    render json: { rental: @rental, bookings: @rental.bookings }
  end

  # POST /rentals
  def create
    @rental = Rental.new(rental_params)

    if @rental.save
      render json: { rental: @rental }, status: :created, localtion: @rental
    else
      render json: { errors: @rental.errors }  , status: 422
    end
  end

  # PATCH/PUT /rentals/1
  def update
    if @rental.update(rental_params)
      render json: { rental: @rental }
    else
      render json: { errors: @rental.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /rentals/1
  def destroy
    @rental.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rental
      @rental = Rental.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def rental_params
      params.require(:rental).permit(:name, :daily_rates)
    end
end
