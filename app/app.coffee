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
    data = { latlng }
    success = cb
    error = (jqXHR, textStatus) ->
      console.error 'error when reverse geocoding', latlng
      console.error 'resonse status was', textStatus
      cb()
    $.ajax '/proxy/reverseGeocode', { data, success, error }
  
  vbbGeocode: (address, cb) ->
    data = { address }
    success = (suggestions)->
      if suggestions.length == 1
        cb suggestions[0].id
      else
        console.error "vbb doesn't know address", address
        cb()
    error = (jqXHR, textStatus) ->
      console.error 'error when geocoding via vbb', address
      console.error 'resonse status was', textStatus
      cb()
    $.ajax '/proxy/vbb/suggestions', { data, success, error }

  @handleGeolocation: (position) ->
    app = new App
    lat = position.coords.latitude
    lng = position.coords.longitude
    console.log "you are at:", lat, lng 
    bath = app.findBath position
    console.log "closest bath:", bath.name
    await app.reverseGeocode lat, lng, defer address
    console.log "closest address:", address
    bathIDs = []
    await
      app.vbbGeocode address, defer myID
      for bath, i in Baths
        app.vbbGeocode bath.address, defer bathIDs[i]
    console.log "my", myID, bathIDs[0]