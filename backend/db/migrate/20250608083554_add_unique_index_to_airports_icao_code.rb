class AddUniqueIndexToAirportsIcaoCode < ActiveRecord::Migration[7.2]
  def change
    add_index :airports, :icao_code, unique: true
  end
end
