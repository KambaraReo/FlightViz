require 'rails_helper'

RSpec.describe "Api::V1::Airports", type: :request do
  describe "GET /api/v1/airports/" do
    let!(:small_airports) { create_list(:airport, 2, status: 0) }
    let!(:large_airports) { create_list(:airport, 3, status: 1) }
    let(:json) { JSON.parse(response.body) }

    context "when status params is '0'" do
      it "returns 200 and only small airports" do
        get "/api/v1/airports?status=0", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(json.length).to eq(2)
        expect(json).to all(include("country_code", "icao_code", "label", "lat", "lon"))
        json.each do |airport|
          expect(airport).not_to include("uri", "status")
        end
      end
    end

    context "when status params is '1'" do
      it "returns 200 and only large airports" do
        get "/api/v1/airports?status=1", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(json.length).to eq(3)
        expect(json).to all(include("country_code", "icao_code", "label", "lat", "lon"))
        json.each do |airport|
          expect(airport).not_to include("uri", "status")
        end
      end
    end

    context "when status param is not given" do
      it "returns 200 and all airports" do
        get "/api/v1/airports", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(json.length).to eq(5)
        expect(json).to all(include("country_code", "icao_code", "label", "lat", "lon"))
        json.each do |airport|
          expect(airport).not_to include("uri", "status")
        end
      end
    end

    context "when status params does not match any airport" do
      it "returns 404 and error message" do
        get "/api/v1/airports?status=99", headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:not_found)
        expect(json).to eq({ "error" => "Not Found" })
      end
    end
  end
end
