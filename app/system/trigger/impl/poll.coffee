# Trigger implementation for polling

Bacon = require 'baconjs'
juration = require 'juration'

module.exports = (config) ->
	interval = juration.parse config.interval, defaultUnit: 'minutes'
	Bacon.interval interval * 1000, reason: 'poll interval'
