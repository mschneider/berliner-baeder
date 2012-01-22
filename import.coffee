berlin = require './berlin.json'
fs = require 'fs'
request = require 'request'
$ = require 'jQuery'
_ = require 'underscore'
_.str = require 'underscore.string'
_.mixin _.str.exports()

baseUrl = 'http://www.berlinerbaederbetriebe.de/'

parseBath = (body) ->
  name = $(body).find('#content h1:first').text()
  features = []
  text = $(body).find('#content').text()
  features.push '25-m-Becken' if _.str.include text, '25-m-Becken'
  features.push '50-m-Becken' if _.str.include text, '50-m-Becken'
  time_table = $(body).find('#content_ul > table:first')
  bath =
    'name': name,
    'features': features,
    'openingTimes': parseTimeTable time_table

parseBathList = (body, cb) ->
  bathLinks = $(body).find('div#content > p > a')
  result = []
  returnResult = _.after bathLinks.length, () ->
    cb(result)
  bathLinks.each (index, bathLink) ->
    href = $(bathLink).attr 'href'
    request baseUrl + href, (error, response, body) ->
      if !error and response.statusCode == 200
        result.push parseBath body
        returnResult()

parseTimeTable = (table) ->
  result = {}
  lastDay = undefined
  $(table).find('tr').each (index, row) ->
    [day, time, comment] = _.map $(row).find('td'), (node) ->
      _.trim $(node).text()
    day ||= lastDay
    result[day] ||= {}
    result[day][time] = comment
    # save last day
    lastDay = day
  result

request baseUrl + '24.html', (error, response, body) ->
  if !error and response.statusCode == 200
    parseBathList body, (baths) ->
      console.log JSON.stringify baths
      # fs.writeFile 'baths.json', JSON.stringify(baths), (err) ->
      #  if (err) throw err
      # console.log "Imported into baths.json"
