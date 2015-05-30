# Configuration/setup for express

express = require 'express'
config = require 'config'

logger = require './logger'

bodyParser = require 'body-parser'

path = require 'path'
root = path.normalize "#{__dirname}/.."

app = express()

# Setup Jade to render templates from app/views
app.engine 'jade', (require 'jade').__express
app.set 'views', "#{root}/app/views"
app.set 'view engine', 'jade'

app.use (req, res, next) ->
	res.locals.config = config
	next()

app.use bodyParser.json()

(require './routes') app

server = app.listen config.get('system.port'), () ->
	logger.info "Awesome Build started at #{server.address().address}:#{server.address().port}"

module.exports = app
