# Trigger implementation for being told when to poll

Bacon = require 'baconjs'
router = require '../../../router'

module.exports = (config) ->
	bus = new Bacon.Bus

	url = if config.url? then "/repo/poll/#{url}" else '/repo/poll'
	router.api.post url, (req, res) ->
		bus.push reason: "request from #{req.ip}"
		res.sendStatus 202

	bus.toEventStream()
