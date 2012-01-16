unless ARGV.count == 1
  puts "usage: ruby convert_vbb_data.rb stationlist.csv >stationlist.json"
  exit 1
end
require 'json'
stations = []
input = File.open ARGV.first
input.each do |line|
  nr, name, place, lon, lat, gk4x, gk4y = line.split ","
  next if nr == "Nr."
  station = { :nr => nr, :name => name, :place => place, :lon => lon,
      :lat => lat, :gk4x => gk4x, :gk4y => gk4y }
  stations << station
end
puts "Stations = #{stations.to_json}"
