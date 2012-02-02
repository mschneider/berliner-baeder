{print}       = require 'util'
{spawn, exec} = require 'child_process'

build = (watch) ->
  buildApp watch
  buildNode 'import', watch
  buildNode 'server', watch

buildApp = (watch) ->
  options = ['-I', 'inline', '-b', '-o', 'public', '-c', 'app']
  options.unshift '-w' if watch
  compile options

buildNode = (name, watch) ->
  options = ['-c', name]
  options.unshift '-w' if watch
  compile options 

compile = (options) ->
  exec 'node_modules/iced-coffee-script/bin/coffee', options

exec = (command, options) ->
  process = spawn command, options
  process.stdout.on 'data', (data) -> print data.toString()
  process.stderr.on 'data', (data) -> print data.toString()

task 'build', 'Compile CoffeeScript source files', ->
  build false

task 'import', 'Import Baths', ->
  buildNode 'import', false
  exec 'node', ['import.js']

task 'server', 'Start Server', ->
  buildNode 'server', false
  exec 'node', ['server.js']
  
task 'watch', 'Recompile CoffeeScript source files when modified', ->
  build true