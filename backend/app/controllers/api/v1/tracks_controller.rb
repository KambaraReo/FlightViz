class Api::V1::TracksController < ApplicationController
  def available_dates
    dates = Track.select("DATE(timestamp) AS date").distinct.order("date").map { |track| track.date }

    if dates.any?
      render json: dates.as_json, status: :ok
    else
      render json: { error: "Not Found" }, status: :not_found
    end
  end

  def flight_ids
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
      rescue ArgumentError
        return render json: { error: "Invalid date format" }, status: :bad_request
      end

      flight_ids = Track
        .where(timestamp: date.beginning_of_day..date.end_of_day)
        .distinct
        .order(:flight_id)
        .pluck(:flight_id)
    else
      flight_ids = Track.distinct.order(:flight_id).pluck(:flight_id)
    end

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
