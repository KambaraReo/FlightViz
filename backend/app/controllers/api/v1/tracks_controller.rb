class Api::V1::TracksController < ApplicationController
  def flight_ids
    flight_ids = Track.distinct.order(:flight_id).pluck(:flight_id)

    if flight_ids.any?
      render json: flight_ids.as_json, status: :ok
    else
      render json: { error: "Not Found" }, status: :not_found
    end
  end

  def flight_track
    track_points =Track.where(flight_id: params[:flight_id]).order(:timestamp)

    if track_points.any?
      render json: track_points.as_json(only: %i[timestamp flight_id lat lon alt aircraft_type]), status: :ok
    else
      render json: { error: "Not Found" }, status: :not_found
    end
  end
end
