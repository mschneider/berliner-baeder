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
    data = { latlng: lat + ',' + lng }
    error = (jqXHR, textStatus) ->
      console.error 'error when reverse geocoding', latlng
      console.error 'resonse status was', textStatus
      cb()
    $.ajax '/proxy/reverseGeocode', { data, success: cb, error }
  
  vbbGeocode: (address, cb) ->
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
    $.ajax '/proxy/vbb/suggestions', { data: { address }, success, error }
  
  vbbConnections: (origin, destination , cb) ->
    error = (jqXHR, textStatus) ->
      console.error 'error when fetching connections via vbb', origin, destination
      console.error 'resonse status was', textStatus
      cb()
    $.ajax '/proxy/vbb/connections', { data: { origin, destination }, success: cb, error }
  
  bathConnections: (origin, bath, cb) ->
    @vbbGeocode bath.address, (destination) =>
      @vbbConnections origin, destination, (connections) ->
        cb connections

  @handleGeolocation: (position) ->
    app = new App
    lat = position.coords.latitude
    lng = position.coords.longitude
    log "you are at:", lat, lng 
    bath = app.findBath position
    log "closest bath:", bath.name
    await app.reverseGeocode lat, lng, defer address
    log "closest address:", address
    await app.vbbGeocode address, defer origin
    log "origin:", origin
    await app.bathConnections origin, b, defer b.connections for b in Baths
    log "fetched baths"
    closestBath = Baths.reduce (l, r) ->
      for o in [l, r] 
        o.firstArrivingConnection ||= o.connections.reduce (l, r) ->
          if r.time.arrival < l.time.arrival then r else l
      if r.firstArrivingConnection.time.arrival < l.firstArrivingConnection.time.arrival then r else l
    log "first possible arrival at:", closestBath.firstArrivingConnection.time.arrival
    log "closest Bath via VBB is:", closestBath.name

log = ->
  console.log new Date, arguments...