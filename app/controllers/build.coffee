# API controller for builds

Branch = require '../models/branch'

async = require 'async'

module.exports =
	load: (req, res, next, id) ->
		req.build = req.branch?.builds.id id
		return next new Error('not found') if not req.build?
		next()

	latest: (req, res, next) ->
		branch.builds.latest (err, latest) ->
			return next err if err?
			return next new Error('not found') if not latest?
			res.json latest

	list: (req, res, next) ->
		#TODO: pagination?
		#options = page: (req.query.page ? 1) - 1, perPage: (req.query.perPage ? 30)
		res.json req.branch.builds

	get: (req, res) -> res.json req.build
