# The system all set up as a whole

config = require 'config'

repoManager = do ->
	RepoManager = require './repo'
	repoType = config.get 'repository.type'
	repoConfig = config.get 'repository'
	dataDir = config.get 'system.dataDirectory'
	new RepoManager repoType, repoConfig, dataDir

triggerManager = do ->
	TriggerManager = require './trigger'
	new TriggerManager repoManager, config.get 'triggers'

module.exports =
	repo: repoManager
	triggers: triggerManager
