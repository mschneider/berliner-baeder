berlin = require './berlin.json'
fs = require 'fs'
gm = require 'googlemaps'
request = require 'request'
$ = require 'jQuery'
_ = require 'underscore'
_.str = require 'underscore.string'
_.mixin _.str.exports()

baseUrl = 'http://www.berlinerbaederbetriebe.de/'

class BathParser
  constructor: (@body) ->

  run: (cb) ->
    result =
      address: this.address()
      name: this.name()
      laneLength: this.laneLength()
      openingTimes: this.openingTimes()
    gm.geocode result.address, (error, response) ->
      if !error and response.status == 'OK'
        location = response.results[0].geometry.location
        result.location = { lat: location.lat, lng: location.lng }
        console.log 'finished', result.name
        cb(result)
      else
        console.log 'could not geocode', result.address
        cb()
  
  address: ->
    lines = @body.find('#content_left p:first b').html().split '<br>'
    lines[0] + ', ' + lines[1]

  name: ->
    @body.find('#content h1:first').text()

  laneLength: ->
    content = @body.find('#content').text()
    if _.str.include content, '50-m-Becken'
      '50m'
    else
      '25m'

  openingTimes: ->
    result = {}
    lastDay = ''
    that = this
    @body.find('#content_ul > table:first tr').each (index, row) ->
      [day, time, comment] = _.map $(row).find('td'), (node) ->
        _.trim $(node).text()
      day ||= lastDay
      that.addTimeTableEntry result, day, time, comment if time
      lastDay = day
    result

  cleanComment: (comment) ->
    if _.str.include comment, 'Parallelbetrieb'
      comment = _.str.insert comment, 'Parallelbetrieb'.length, ' '
      comment = comment.split('/ ').join('/')
    comment = _.trim comment, '*'

  addTimeTableEntry: (openingTimes, day, time, comment) ->  
    [from, to] = time.split(' - ')
    comment = this.cleanComment(comment)
    if comment
      newEntry = { from, to, comment }
    else
      newEntry = { from, to } # saves 10%
    openingTimes[day] ||= []
    openingTimes[day].push newEntry


baths = []

writeBaths = () ->
  openedBaths = _.reject baths, (bath) ->
    _.isEmpty bath.openingTimes
  content = 'Baths = ' + JSON.stringify openedBaths
  console.log 'writing to baths.json'
  fs.writeFile 'baths.json', content, (err) ->
    throw err if err

request baseUrl + '24.html', (error, response, body) ->
  if !error and response.statusCode == 200
    bathLinks = $(body).find('div#content > p > a')
    requestFinished = _.after bathLinks.length, writeBaths
    console.log 'crawling', bathLinks.length, 'baths'
    bathLinks.each (index, bathLink) ->
      href = $(bathLink).attr 'href'
      request baseUrl + href, (error, response, body) ->
        if !error and response.statusCode == 200
          new BathParser($(body)).run (bath) ->
            baths.push bath if bath
            requestFinished()
        else
          console.log 'could not fetch:', baseUrl + href
          requestFinished()



