berlin = require './berlin.json'
request = require 'request'
$ = require 'jQuery'

baseUrl = 'http://www.berlinerbaederbetriebe.de/'

parseBath = (body) ->
  $(body).find('div#content > p').each (index, p) ->
    console.log $(p).text()

parseBathList = (body) ->
  $(body).find('div#content > p > a').each (index, bathLink) ->
    href = $(bathLink).attr 'href'
    request baseUrl + href, (error, response, body) ->
      if !error and response.statusCode == 200
        console.log "found bath", href


request baseUrl + '24.html', (error, response, body) ->
  if !error and response.statusCode == 200
    parseBathList body
