class Bath
  constructor: (other) ->
    for k,v of other
      this[k] = v
    @lat = Number(@location.lat)
    @lng = Number(@location.lng)

  distanceTo: (lat, lng) ->
    x = (@lng - lng) * Math.cos((lat + @lat)/2)
    y =  @lat - lat
    Math.sqrt(x*x + y*y)

  closingTime: ->
    _.last(_.sortBy(@todaysTimes, (opened) -> opened.to)).to

  firstArrivalTime: ->
    @connections[0].time.arrival

  isOpen: (day, time) ->
    @todaysTimes ||= @openingTimes[day]
    if @todaysTimes?
      for opened in @todaysTimes
        if opened.from <= time and opened.to > time
          return true
    return false

  fetchConnections: (origin, cb) ->
    VBB.geocode @address, (destination) =>
      VBB.connections origin, destination, (result) =>
        @connections = _.sortBy result, (connection) -> connection.time.arrival
        cb?()

  @all: ->
    (new Bath(b) for b in Baths)


class App
  constructor: (position) ->
    @lat = position.coords.latitude
    @lng = position.coords.longitude
    @setDate new Date()
    @openedBaths = (bath for bath in Bath.all() when bath.isOpen @day, @time)
    @baths = _.sortBy(@openedBaths, (bath) => bath.distanceTo @lat, @lng)[0..9]

  setDate: (date) ->
    @day = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"][date.getDay()]
    @time = @formatTime date.getHours(), date.getMinutes(), 45

  formatTime: (hours, minutes, minuteOffset) ->
    inverseMinuteOffset = 60 - minuteOffset
    if minutes < inverseMinuteOffset
      minutes += minuteOffset
    else
      minutes -= inverseMinuteOffset
      hours += 1
    "#{hours}:#{minutes}"

  fetchBathConnections: (cb) ->
    await reverseGeocode @lat, @lng, defer @address
    await VBB.geocode @address, defer @origin
    await bath.fetchConnections @origin, defer() for bath in @baths
    bathIsOpenUponArrival = (bath) =>
      time = bath.firstArrivalTime()
      [hours, minutes] = time.split ":"
      time = @formatTime hours, minutes, 45
      bath.isOpen @day, time
    @baths = (b for b in @baths when bathIsOpenUponArrival(b))
    @baths = _.sortBy @baths, (b) -> b.firstArrivalTime()
    cb()

  @handleGeolocation: (position) ->
    app = new App(position)
    log "you are at: (#{app.lat}, #{app.lng})"
    log "#{app.baths.length} baths are still opened"
    await app.fetchBathConnections defer()
    log "#{app.baths.length} baths will be open upon arrival"
    log b.name, b.firstArrivalTime(), b.closingTime() for b in app.baths

class VBB
  @geocode: (address, cb) ->
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

  @connections: (origin, destination , cb) ->
    error = (jqXHR, textStatus) ->
      console.error 'error when fetching connections via vbb', origin, destination
      console.error 'resonse status was', textStatus
      cb()
    $.ajax '/proxy/vbb/connections', { data: { origin, destination }, success: cb, error }

reverseGeocode = (lat, lng, cb) ->
  data = { latlng: lat + ',' + lng }
  error = (jqXHR, textStatus) ->
    console.error 'error when reverse geocoding', latlng
    console.error 'resonse status was', textStatus
    cb()
  $.ajax '/proxy/reverseGeocode', { data, success: cb, error }

log = ->
  console.log new Date, arguments...
