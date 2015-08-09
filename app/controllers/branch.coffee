# API controller for branches

logger = require '../logger'
Branch = require '../models/branch'

async = require 'async'
sse = require('express-sse-stream').sse

module.exports =
	loadByName: (req, res, next, name) ->
		Branch.find { name }, (err, branch) ->
			return next err if err?
			return next new Error('not found') if not branch?
			req.branch = branch
			next()

	loadById: (req, res, next, id) ->
		Branch.findById id, (err, branch) ->
			return next err if err?
			return next new Error('not found') if not branch?
			req.branch = branch
			next()

	list: (req, res, next) ->
		options = page: (req.query.page ? 1) - 1, perPage: (req.query.perPage ? 30)

		Branch.list options, (err, branches) ->
			return next err if err?
			res.json branches

	get: (req, res) -> res.json req.branch

	setState: (req, res, next) ->
		#TODO: validate state
		req.branch.state = req.body.state
		req.branch.save (err, branch) ->
			return next err if err?
			res.json branch

	stream: [
		sse()
		(req, res) ->
			logger.debug "opening sse branch stream for #{req.ip}"

			subs = [
				Branch.creation.onValue (branch) -> req.sse.stream.write event: 'created', data: branch
				Branch.modification.onValue (branch) -> req.sse.stream.write event: 'modified', data: branch
			]

			req.sse.stream.on 'finish', ->
				logger.debug "#{req.ip} disconnected from branch stream"
				unsub() for unsub in subs
	]
