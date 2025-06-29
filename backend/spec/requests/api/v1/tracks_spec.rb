require 'rails_helper'

RSpec.describe "Api::V1::Tracks", type: :request do
  # FactoryBotのシーケンスをテストケース毎にリセット
  before(:each) do
    FactoryBot.reload
  end

  describe "GET /api/v1/flights/available_dates" do
    let(:json) { JSON.parse(response.body) }

    context "when tracks exist" do
      let!(:tracks) do
        list = create_list(:track, 4)
        list[1].update!(timestamp: list[0].timestamp)
        list
      end
      let(:expected_dates) { ["2025-01-01", "2025-01-03", "2025-01-04"] }

      it "returns 200 and a unique list of available dates for tracks" do
        get "/api/v1/flights/available_dates", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(json).to eq(expected_dates)
      end
    end

    context "when tracks does not exist" do
      it "returns 404 with error message" do
        get "/api/v1/flights/available_dates", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Not Found")
      end
    end
  end

  describe "GET /api/v1/flights" do
    let(:json) { JSON.parse(response.body) }

    context "when tracks exists" do
      let!(:track1) { create(:track, flight_id: "TEST00001", timestamp: "2025-06-28T10:00:00Z") }
      let!(:track2) { create(:track, flight_id: "TEST00002", timestamp: "2025-06-29T12:00:00Z") }
      let!(:track3) { create(:track, flight_id: "TEST00003", timestamp: "2025-06-29T15:00:00Z") }

      it "returns all flight_ids when no date param is given" do
        get "/api/v1/flights", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(json.length).to eq(3)
        expect(json).to contain_exactly("TEST00001", "TEST00002", "TEST00003")
      end

      it "returns filtered flight_ids by date param" do
        get "/api/v1/flights", params: { date: "2025-06-29" }, headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(json.length).to eq(2)
        expect(json).to contain_exactly("TEST00002", "TEST00003")
      end
    end

    context "when no tracks match given date" do
      let!(:track) { create(:track, flight_id: "TEST00001", timestamp: "2025-06-28T10:00:00Z") }

      it "returns 404 with error" do
        get "/api/v1/flights", params: { date: "2025-06-29" }, headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Not Found")
      end
    end

    context "when tracks does not exist at all" do
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
