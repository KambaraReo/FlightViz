require "csv"
require "activerecord-import"

namespace :airports do
  # ex) rails airports:import_file_data[jp-airport.csv]
  desc "Import Airports CSV file under lib/data"
  task :import_file_data, [:filename] => :environment do |_t, args|
    base_path = Rails.root.join("lib", "data")
    file_path = base_path.join(args[:filename].to_s)

    if File.exist?(file_path)
      import_ap_csv(file_path)
      puts "#{args[:filename]} imported!"
    else
      puts "File not found: #{args[:filename]}"
    end
  end

  def import_ap_csv(file_path)
    puts "Importing #{file_path}..."
    new_airports = []
    total_count = 0
    imported_count = 0

    Track.transaction do
      CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
        next if row.to_h.values.compact.all?(&:blank?)

        total_count += 1

        new_airports << Airport.new(
          country_code: row[:country_code],
          icao_code: row[:icao_code],
          label: row[:label],
          lat: row[:lat].to_f,
          lon: row[:lon].to_f,
          uri: row[:uri],
          status: row[:status].to_i
        )

        # バルクインサート（100件ごと）
        if new_airports.size >= 100
          result = Airport.import(new_airports, on_duplicate_key_ignore: true)
          imported_count += result.ids.size
          new_airports.clear
        end
      end

      # 最後の残りをインポート
      unless new_airports.empty?
        result = Airport.import(new_airports, on_duplicate_key_ignore: true)
        imported_count += result.ids.size
      end

      skipped_count = total_count - imported_count
      puts "Total: #{total_count}, Imported: #{imported_count}, Skipped (duplicates): #{skipped_count}"
    end
  end
end
