# Main server startup/entry point

fs = require 'fs'
express = require 'express'
mongoose = require 'mongoose'

env = require './config/env'
config = require './config/config'

# Setup mongo connection
connect = () ->
	mongoose.connect env.db, server: socketOptions: keepAlive: 1

connect()

mongoose.connection.on 'error', console.log
mongoose.connection.on 'disconnected', connect

# Set up express
app = express()

(require './config/express') app
(require './app/routes') app

server = app.listen process.env.PORT or 3824, () ->
	console.log "BuildZone started at #{server.address().address}:#{server.address().port}"

module.exports = app
