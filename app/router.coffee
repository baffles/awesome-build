# Main router for everything

express = require 'express'
logger = require './logger'

is404 = (err) ->
	# we treat errors as 404 under certain circumstances
	/\bnot found\b|\bCast to ObjectId failed\b/.test err?.message

appRouter = express.Router()
apiRouter = express.Router()

module.exports =
	app: appRouter
	api: apiRouter
	init: (app) ->
		appRouter.get '/', (req, res) ->
			res.render 'index', title: 'Home'

		apiRouter.use '/branch', require './api/branch'
		apiRouter.use '/repo', require './api/repo'

		apiRouter.use (err, req, res, next) ->
			return next() if is404 err
			logger.error 'error serving API request', err
			res.sendStatus 500

		apiRouter.use (req, res) ->
			res.sendStatus 404

		app.use appRouter
		app.use '/api', apiRouter

		app.use (err, req, res, next) ->
			return next() if is404 err
			logger.error 'error serving request', err
			res.status(500).render('500', { error: err.message })

		app.use (req, res) ->
			# assume 404 at this point, since no middleware responded and our error handler ignored the error
			res.status(404).render('404', { url: req.originalUrl, error: 'Not found', })
