class AddUniqueIndexToTracks < ActiveRecord::Migration[7.2]
  def change
    add_index :tracks, [:timestamp, :flight_id], unique: true
  end
end
