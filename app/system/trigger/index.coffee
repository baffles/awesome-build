# Manages triggers for repository updates

logger = require '../../logger'

module.exports = class TriggerManager
	constructor: (@repoManager, triggers) ->
		@triggers = (@init trigger for trigger in triggers)

	init: (trigger) ->
		name = trigger.name ? trigger.type
		impl = require "./impl/#{trigger.type}"
		stream = impl trigger
		stream.onValue (reason) =>
			logger.debug "#{name} triggered a repository update", reason
			@repoManager.update (err) ->
				logger.error "error on repository update triggered by #{name}", err if err?
