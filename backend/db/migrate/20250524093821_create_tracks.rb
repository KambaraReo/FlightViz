class CreateTracks < ActiveRecord::Migration[7.2]
  def change
    create_table :tracks do |t|
      t.datetime :timestamp
      t.string :flight_id
      t.float :lat
      t.float :lon
      t.integer :alt
      t.string :type

      t.timestamps
    end
  end
end
