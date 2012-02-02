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
      component.long_name
    result = [parse('postal_code'), parse('route'), parse('street_number')].join ' '
    console.log '[GET]', req.url, '->', result
    res.send result

port = process.env.PORT || 8080;
app.listen port, ->
  console.log 'server listening at port', port
