express = require 'express'
app = express()
app.use express.static __dirname + '/public'

_ = require 'underscore'
gm = require 'googlemaps'
app.get '/proxy/reverseGeocode', (req, res) ->
  gm.reverseGeocode req.param('latlng'), (err, response) ->
    components = _.map response.results[0].address_components, (component) ->
      part = component.types[0]
      value = component.long_name
      { part, value }
    postal_code = _.find(components, (c) -> c.part == 'postal_code').value
    route = _.find(components, (c) -> c.part == 'route').value
    street_number = _.find(components, (c) -> c.part == 'street_number').value
    result = [postal_code, route, street_number].join ' '
    console.log '[GET]', req.url, '->', result
    res.send result

app.listen 8080
console.log 'server listening at port 8080'