# API controller for builds

logger = require '../logger'
Build = require '../models/build'

async = require 'async'
sse = require('express-sse-stream').sse

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

	stream: [
		sse()
		(req, res) ->
			logger.debug "opening sse build stream for #{req.ip}"

			branchFilter = (build) -> build.branchId.equals req.branch._id

			subs = [
				Build.creation.filter(branchFilter).onValue (build) -> req.sse.stream.write event: 'created', data: build
				Build.modification.filter(branchFilter).onValue (build) -> req.sse.stream.write event: 'modified', data: build
			]

			req.sse.stream.on 'finish', ->
				logger.debug "#{req.ip} disconnected from build stream"
				unsub() for unsub in subs
	]
