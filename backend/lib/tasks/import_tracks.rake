require "csv"
require "activerecord-import"

namespace :import do
  # rails import:all_tracks
  desc "Import all CSV files under lib/data recursively"
  task all_tracks: :environment do
    base_path = Rails.root.join("lib", "data")

    # Dir.globで再帰的にcsvファイル取得
    csv_files = Dir.glob("#{base_path}/**/*.csv")

    csv_files.each do |file_path|
      import_csv(file_path)
    end

    puts "All CSV files imported!"
  end

  # ex) rails import:track[201904]
  desc "Import all CSV files under the specified directory in lib/data"
  task :track_dir, [:dirname] => :environment do |_t, args|
    base_path = Rails.root.join("lib", "data")
    dir_path = base_path.join(args[:dirname].to_s)

    if Dir.exist?(dir_path)
      csv_files = Dir.glob("#{dir_path}/**/*.csv")
      if csv_files.empty?
        puts "No CSV files found in #{args[:dirname]}"
      else
        csv_files.each do |file_path|
          import_csv(file_path)
          puts "#{file_path.sub("#{Rails.root}/", "")} imported!"
        end
      end
    else
      puts "Directory not found: #{args[:dirname]}"
    end
  end

  # ex) rails import:track[201904/trk20190422_00_12.csv]
  desc "Import specified CSV file under lib/data"
  task :track_file, [:filename] => :environment do |_t, args|
    base_path = Rails.root.join("lib", "data")
    file_path = base_path.join(args[:filename].to_s)

    if File.exist?(file_path)
      import_csv(file_path)
      puts "#{args[:filename]} imported!"
    else
      puts "File not found: #{args[:filename]}"
    end
  end

  def import_csv(file_path)
    puts "Importing #{file_path}..."
    new_tracks = []
    total_count = 0
    imported_count = 0

    filename = File.basename(file_path)
    if filename =~ /(\d{4})(\d{2})(\d{2})/
      base_date = Date.new($1.to_i, $2.to_i, $3.to_i)
    else
      puts "ファイル名から日付を抽出できません: #{filename}"
      return
    end

    Track.transaction do
      CSV.foreach(file_path, headers: %i[timestamp flight_id lat lon alt aircraft_type]) do |row|
        total_count += 1

        begin
          time_str = row[:timestamp].to_s
          datetime_str = "#{base_date} #{time_str}" # => ex)"2019-04-22 11:59:59.3"
          timestamp = DateTime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S.%L") rescue DateTime.parse(datetime_str)
        rescue => e
          puts "Invalid timestamp: #{row[:timestamp]}, error: #{e.message}"
          next
        end

        new_tracks << Track.new(
          timestamp: timestamp,
          flight_id: row[:flight_id],
          lat: row[:lat].to_f,
          lon: row[:lon].to_f,
          alt: row[:alt].to_i,
          aircraft_type: row[:aircraft_type]
        )

        # バルクインサート（5000件ごと）
        if new_tracks.size >= 5000
          result = Track.import(new_tracks, on_duplicate_key_ignore: true)
          imported_count += result.ids.size
          new_tracks.clear
        end
      end

      # 最後の残りをインポート
      unless new_tracks.empty?
        result = Track.import(new_tracks, on_duplicate_key_ignore: true)
        imported_count += result.ids.size
      end

      skipped_count = total_count - imported_count
      puts "Total: #{total_count}, Imported: #{imported_count}, Skipped (duplicates): #{skipped_count}"
    end
  end
end
