App = {
  distance: (position, bath) ->
    lat1 = position.coords.latitude
    lng1 = position.coords.longitude
    lat2 = Number(bath.location.lat)
    lng2 = Number(bath.location.lng)
    x = (lng2-lng1) * Math.cos((lat1+lat2)/2)
    y = (lat2-lat1)
    Math.sqrt(x*x + y*y); 

  findBaths: (position) ->
    console.log "you are at:", position.coords.latitude, position.coords.longitude
    for bath in Baths
      closestBath ||= bath
      bath.distance = App.distance(position, bath)
      if closestBath.distance > bath.distance
        closestBath = bath
    console.log "closest bath:", closestBath
}
