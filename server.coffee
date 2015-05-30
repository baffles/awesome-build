# Main server startup/entry point

fs = require 'fs'
express = require 'express'
mongoose = require 'mongoose'

env = require './config/env'
config = require './config/config'
logger = require './config/logger'

# Setup mongo connection
connect = () ->
	logger.debug('connecting to mongo...')
	mongoose.connect env.db, server: socketOptions: keepAlive: 1

connect()

mongoose.connection.on 'error', (err) -> logger.error('mongoose error', err)
mongoose.connection.on 'disconnected', connect

# Set up express
app = express()

(require './config/express') app
(require './app/routes') app

server = app.listen process.env.PORT or 3824, () ->
	logger.info "Awesome Build started at #{server.address().address}:#{server.address().port}"

module.exports = app
