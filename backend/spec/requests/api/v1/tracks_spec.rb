require 'rails_helper'

RSpec.describe "Api::V1::Tracks", type: :request do
  describe "GET /api/v1/flights" do
    let(:json) { JSON.parse(response.body) }

    context "when tracks exists" do
      let!(:tracks) { create_list(:track, 3) }

      it "returns 200 and the flight_ids for tracks" do
        get "/api/v1/flights", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(json.length).to eq(3)
        json.each.with_index(1) do |flight_id, i|
          expect(flight_id).to eq("TEST#{i.to_s.rjust(5, '0')}")
        end
      end
    end

    context "when tracks does not exist" do
      it "returns 404 with error" do
        get "/api/v1/flights", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Not Found")
      end
    end
  end

  describe "GET /api/v1/flights/:flight_id/track" do
    let(:flight_id) { "TEST00001" }
    let!(:tracks) { create_list(:track, 3, flight_id: flight_id) }
    let(:json) { JSON.parse(response.body) }

    context "when flight_id exists" do
      it "returns 200 and the tracks for the flight" do
        get "/api/v1/flights/#{flight_id}/track", headers: { "ACCEPT" => "application/json" }

        timestamps = json.map { |t| Time.parse(t["timestamp"]) }

        expect(response).to have_http_status(:ok)
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
        get "/api/v1/flights/UNKNOWN99999/track", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Not Found")
      end
    end
  end
end
