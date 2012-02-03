express = require 'express'
app = express()
# app.use express.logger()
app.use express.static __dirname + '/public'

_ = require 'underscore'
gm = require 'googlemaps'
app.get '/proxy/reverseGeocode', (req, res) ->
  gm.reverseGeocode req.param('latlng'), (err, response) ->
    parse = (attribute) ->
      component = _.find response.results[0].address_components, (c) ->
        attribute in c.types
      component.long_name if component
    result = [parse('postal_code'), parse('route'), parse('street_number')].join ' '
    console.log '[GET]', req.url, '->', result
    res.send result

qs = require 'qs'
request = require 'request'
app.get '/proxy/vbb/suggestions', (req, res) ->
  start = 1
  REQ0JourneyStopsS0A = req.param('type') || 2
  REQ0JourneyStopsB = req.param('count') || 1
  S = req.param('address')
  params = { start, REQ0JourneyStopsS0A, REQ0JourneyStopsB, S }
  url = 'http://www.vbb-fahrinfo.de/hafas/ajax-getstop.exe/doy?' + qs.stringify params
  request {url, encoding: 'binary'}, (error, response, body) ->
    if not error and response.statusCode == 200
      pattern = /^SLs\.sls=(.+);SLs\.showSuggestion\(\);$/
      { suggestions } = JSON.parse pattern.exec(body)[1]
      console.log '[GET]', req.url, '->', suggestions.length, 'suggestion'
      res.send suggestions

port = process.env.PORT || 8080;
app.listen port, ->
  console.log 'server listening at port', port
