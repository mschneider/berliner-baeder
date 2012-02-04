express = require 'express'
app = express()
# app.use express.logger()
app.use express.static __dirname + '/public'

_ = require 'underscore'
gm = require 'googlemaps'
app.get '/proxy/reverseGeocode', (req, res) ->
  console.log '[GET] /proxy/reverseGeocode', req.query
  gm.reverseGeocode req.param('latlng'), (err, response) ->
    parse = (attribute) ->
      component = _.find response.results[0].address_components, (c) ->
        attribute in c.types
      component.long_name if component
    result = [parse('postal_code'), parse('route'), parse('street_number')].join ' '
    console.log '  ↪', result
    res.send result

$ = require 'jquery'
qs = require 'qs'
request = require 'request'
chrono = require 'chrono'
_.str = require 'underscore.string'
_.mixin _.str.exports()

vbb_suggest_url = (address, count, type) ->
  REQ0JourneyStopsS0A = type || 2
  REQ0JourneyStopsB = count || 1
  params = { start: 1, REQ0JourneyStopsS0A, REQ0JourneyStopsB, S: address }
  'http://www.vbb-fahrinfo.de/hafas/ajax-getstop.exe/doy?' + qs.stringify params

vbb_suggest = (address, count, type, cb) ->    
  cb ||= type || count
  url = vbb_suggest_url(address, count, type)
  request {url, encoding: 'binary'}, (error, response, body) ->
    if not error and response.statusCode == 200
      pattern = /^SLs\.sls=(.+);SLs\.showSuggestion\(\);$/
      match = pattern.exec(body)
      if match and match.length == 2
        { suggestions } = JSON.parse match[1]
        cb null, suggestions
      else
        cb "could not parse suggestions. probably the vbb changed it's webservice."
    else
      cb(error || ("could not reach vbb server. response status was " + response.statusCode))

app.get '/proxy/vbb/suggestions', (req, res) ->
  vbb_suggest req.param('address'), req.param('count'), req.param('type'), (error, suggestions) ->
    console.log '[GET] /proxy/vbb/suggestions', req.query
    console.log '  ⇄', vbb_suggest_url req.param('address'), req.param('count'), req.param('type')
    console.log '  ↪', suggestions.length, 'suggestion'    
    res.send suggestions

vbb_connections_params = (options) ->
  p = {}
  for option in ["origin", "destination"]
    throw new Error("options." + option + " is a required argument") unless options[option]
  p.REQ0JourneyStopsS0ID = options.origin
  p.REQ0JourneyStopsZ0ID = options.destination
  p.REQ0AddParamBaimprofile = switch options.accessible
    when "barrier-free" then 0
    when "partly" then 1
    else 2
  date = options.date || new Date()
  p.REQ0JourneyDate = date.format 'd.m.Y', 'CET'
  p.REQ0JourneyTime = date.format 'H:i', 'CET'
  p.REQ0HafasSearchForw = if options.arrival? then 0 else 1
  p.REQ0HafasInitialSelection = 0
  p.start = 'Suchen'
  p
  
vbb_more_connections = (body, cb) ->
  link = $(body).find('a').toArray().reduce (l, r) ->
    if $(r).text() == 'Später fahren' then r else l
  url = $(link).attr('href')
  console.log '  ⇄', url
  request {url, encoding: 'binary'}, cb

vbb_connections = (options, cb) ->
  url = 'http://www.vbb-fahrinfo.de/hafas/query.exe/dox'
  params = vbb_connections_params options
  console.log '  ⇄', url
  request {url , encoding: 'binary', form: params, method: 'POST'}, (error, response, body) ->
    # vbb_more_connections body, (error, response, body) ->
      ps = $(body).find('p')
      connections = for p in ps[2..(ps.length - 2)]
        url = $(p).find('a').attr('href')
        times = $(p).find('a').text().split('-')
        time = { departure: times[0], arrival: times[1] } 
        duration = $(p).find('span').text()
        { url, time, duration }
      cb connections

vbb_connection_details = (connection, cb) ->
  console.log '  ⇄', connection.url
  request {url: connection.url, encoding: 'binary'}, (error, response, body) ->
    connection.details = (_.trim $(link).text() for link in $(body).find 'p.details a')
    cb connection

app.get '/proxy/vbb/connections', (req, res) ->
  console.log '[GET] /proxy/vbb/connections', req.query
  await vbb_connections req.query, defer connections
  # await vbb_connection_details c, defer() for c in connections
  console.log '  ↪', connections.length, 'connections'
  res.send connections

port = process.env.PORT || 8080;
app.listen port, ->
  console.log 'server listening at port', port
