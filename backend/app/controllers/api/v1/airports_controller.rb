class Api::V1::AirportsController < ApplicationController
  def index
    airports = params[:status] ? Airport.where(status: params[:status].to_i) : Airport.all

    if airports.any?
      render json: airports.as_json(only: %i[country_code icao_code label lat lon]), status: :ok
    else
      render json: { error: "Not Found" }, status: :not_found
    end
  end
end
