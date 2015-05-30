# API controller for builds

Build = require '../models/build'

async = require 'async'

module.exports =
	loadByRevision: (req, res, next, revision) ->
		Build.findOne { _branch: req.branch._id, revision }, (err, build) ->
			return next err if err?
			return next new Error('not found') if not build?
			req.build = build
			next()

	loadById: (req, res, next, id) ->
		Build.findById id, (err, build) ->
			return next err if err?
			return next new Error('not found') if not build?
			req.build = build
			next()

	latest: (req, res, next) ->
		Build.latest req.branch._id, (err, latest) ->
			return next err if err?
			return next new Error('not found') if not latest?
			res.json latest

	list: (req, res, next) ->
		options = page: (req.query.page ? 1) - 1, perPage: (req.query.perPage ? 30)

		Build.list req.branch._id, options, (err, branches) ->
			return next err if err?
			res.json branches

	get: (req, res) -> res.json req.build
