# API controller for repository actions

{ repoManager } = require '../system'

module.exports =
	forcePoll: (req, res, next) ->
		repoManager.poll (err) ->
			return next err if err?
			res.status(201).end()
