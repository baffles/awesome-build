# Configuration/setup for express

env = require './env'
config = require './config'

bodyParser = require 'body-parser'

module.exports = (app) ->

	# Setup Jade to render templates from app/views
	app.engine 'jade', (require 'jade').__express
	app.set 'views', "#{env.root}/app/views"
	app.set 'view engine', 'jade'

	app.use (req, res, next) ->
		res.locals.env = env
		res.locals.config = config
		next()

	app.use bodyParser.json()
