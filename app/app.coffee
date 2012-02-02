class App
  distance: (position, bath) ->
    lat1 = position.coords.latitude
    lng1 = position.coords.longitude
    lat2 = Number(bath.location.lat)
    lng2 = Number(bath.location.lng)
    x = (lng2-lng1) * Math.cos((lat1+lat2)/2)
    y = (lat2-lat1)
    Math.sqrt(x*x + y*y);
    
  findBath: (position) ->
    for bath in Baths
      closestBath ||= bath
      bath.distance = @distance(position, bath)
      if closestBath.distance > bath.distance
        closestBath = bath
    closestBath
    
  reverseGeocode: (lat, lng, cb) ->
    latlng = lat + ',' + lng
    sensor = false
    data = { latlng, sensor }
    success = cb
    error = (jqXHR, textStatus, errorThrown) ->
      console.error 'error when reverse geocoding', latlng
      console.error 'resonse status was', textStatus
      cb()
    $.ajax 'http://maps.googleapis.com/maps/api/geocode/json', { data, success, error } 

  @handleGeolocation: (position) ->
    app = new App
    lat = position.coords.latitude
    lng = position.coords.longitude
    console.log "you are at:", lat, lng 
    bath = app.findBath position
    console.log "closest bath:", bath.name
    await app.reverseGeocode lat, lng, defer address
    console.log "closest address:", address
    