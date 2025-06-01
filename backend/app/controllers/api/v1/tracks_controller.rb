require "csv"

class Api::V1::TracksController < ApplicationController
  def index
    tracks = Track.all.limit(100)

    render json: tracks
  end
end
