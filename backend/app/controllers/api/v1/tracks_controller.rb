require "csv"

class Api::V1::TracksController < ApplicationController
  def by_flight
    tracks =Track.where(flight_id: params[:flight_id]).order(:timestamp)

    if tracks.any?
      render json: tracks.as_json(only: %i[timestamp flight_id lat lon alt aircraft_type]), status: :ok
    else
      render json: { error: "Not Found" }, status: :not_found
    end
  end
end
