require 'rails_helper'

RSpec.describe "Api::V1::Tracks", type: :request do
  describe "GET /api/v1/flights/:flight_id/tracks" do
    let(:flight_id) { "TEST00001" }
    let!(:tracks) { create_list(:track, 3, flight_id: flight_id) }

    context "when flight_id exists" do
      it "returns 200 and the tracks for the flight" do
        get "/api/v1/flights/#{flight_id}/tracks", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        timestamps = json.map { |t| Time.parse(t["timestamp"]) }

        expect(json.length).to eq(3)
        expect(timestamps).to eq(timestamps.sort)
        # bundle exec rspec --format documentation で puts 出力を確認可能
        # puts "Returned flight_ids: #{json.map { |t| t['flight_id'] }.inspect}"
        expect(json.all? { |t| t["flight_id"] == flight_id }).to be true
        expect(json.first).to include("timestamp", "lat", "lon", "alt", "aircraft_type")
      end
    end

    context "when flight_id does not exist" do
      it "returns 404 with error" do
        get "/api/v1/flights/UNKNOWN99999/tracks", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not Found")
      end
    end
  end
end
