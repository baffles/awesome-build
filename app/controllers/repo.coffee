# API controller for repository actions

#TODO: centralize repomanager's instance somewhere
repoManager = do ->
	RepoManager = require '../system/repo-manager'
	config = require '../../config/config'
	repo = require '../../config/repo'
	new RepoManager repo, config.dataDirectory

module.exports =
	forcePoll: (req, res, next) ->
		repoManager.poll (err) ->
			return next err if err?
			res.status(201).end()
