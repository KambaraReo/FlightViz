class CreateAirports < ActiveRecord::Migration[7.2]
  def change
    create_table :airports do |t|
      t.string :country_code
      t.string :icao_code, null: false
      t.string :label
      t.float :lat
      t.float :lon
      t.string :uri
      t.integer :status

      t.timestamps
    end
  end
end
