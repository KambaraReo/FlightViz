class RenameTypeToAircraftType < ActiveRecord::Migration[7.2]
  def change
    rename_column :tracks, :type, :aircraft_type
  end
end
