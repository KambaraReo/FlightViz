class Airport < ApplicationRecord
  validates :icao_code, presence: true, uniqueness: true
  validates :country_code, :label, :lat, :lon, :status, presence: true
end
