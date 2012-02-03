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
      cb(error || "could not reach vbb server. response status was " + response.statusCode)

app.get '/proxy/vbb/suggestions', (req, res) ->
  vbb_suggest req.param('address'), req.param('count'), req.param('type'), (error, suggestions) ->
    console.log '[GET]', req.url, '->', suggestions.length, 'suggestion'    
    res.send suggestions

port = process.env.PORT || 8080;
app.listen port, ->
  console.log 'server listening at port', port
