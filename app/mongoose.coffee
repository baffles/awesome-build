# Configuration/setup for mongoose

mongoose = require 'mongoose'
config = require 'config'
logger = require './logger'

# Setup mongo connection
connect = () ->
	logger.debug 'connecting to mongo...'
	mongoose.connect config.get('system.db'), server: socketOptions: keepAlive: 1

connect()

mongoose.connection.on 'connected', -> logger.debug 'connected to mongo'
mongoose.connection.on 'disconnected', -> logger.debug 'disconnected from mongo'

mongoose.connection.on 'error', (err) -> logger.error('mongoose error', err)
mongoose.connection.on 'disconnected', connect

module.exports = mongoose
