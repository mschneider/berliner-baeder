App = {
  distance: (position, station) ->
    lat1 = position.coords.latitude
    lat2 = station.lat
    lon1 = position.coords.longitude
    lon2 = station.lon
    x = (lon2-lon1) * Math.cos((lat1+lat2)/2);
    y = (lat2-lat1);
    Math.sqrt(x*x + y*y); 

  findBaths: (position) ->
    console.log "you are at:", position.coords.latitude, position.coords.longtitude
    for station in Stations
      closest ||= station
      station.distance = this.distance(position, station)
      if closest.distance > station.distance
        closest = station
    console.log "closest:", closest
}
