App = {
  distance: (position, station) ->
    lat1 = position.coords.latitude
    lon1 = position.coords.longitude
    lat2 = Number(station.lat)
    lon2 = Number(station.lon)
    x = (lon2-lon1) * Math.cos((lat1+lat2)/2)
    y = (lat2-lat1)
    Math.sqrt(x*x + y*y); 

  findBaths: (position) ->
    console.log "you are at:", position.coords.latitude, position.coords.longitude
    for station in Stations
      closest ||= station
      station.distance = this.distance(position, station)
      if closest.distance > station.distance
        closest = station
    console.log "closest:", closest
}
