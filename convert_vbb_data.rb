unless ARGV.count == 1
  puts "usage: ruby convert_vbb_data.rb berlin.json >stationlist.json"
  exit 1
end
require 'json'
input = File.read ARGV.first
json = JSON.parse input
stations = json[0].map {|k,v| {:id => k, :lat => v["a"], :lng => v["n"], :name => v["o"]}}
puts "Stations = #{stations.to_json}"
