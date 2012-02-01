{print}       = require 'util'
{spawn, exec} = require 'child_process'

build = (watch = false) ->
  buildImport watch
  buildApp watch

buildApp = (watch) ->
  options = ['-I', 'inline', '-b', '-c', 'app']
  options.unshift '-w' if watch
  iced = spawn 'node_modules/iced-coffee-script/bin/coffee', options
  iced.stdout.on 'data', (data) -> print data.toString()
  iced.stderr.on 'data', (data) -> print data.toString()
  
buildImport = (watch) ->
  options = ['-c', 'import']
  options.unshift '-w' if watch
  iced = spawn 'node_modules/iced-coffee-script/bin/coffee', options
  iced.stdout.on 'data', (data) -> print data.toString()
  iced.stderr.on 'data', (data) -> print data.toString()

importBaths = ->
  importer = spawn 'node', ['import.js']
  importer.stdout.on 'data', (data) -> print data.toString()
  importer.stderr.on 'data', (data) -> print data.toString()

task 'build', 'Compile CoffeeScript source files', ->
  build()

task 'import', 'Import Baths', ->
  buildImport false
  importBaths()
  
task 'watch', 'Recompile CoffeeScript source files when modified', ->
  build true