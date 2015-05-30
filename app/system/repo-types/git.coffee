# Repo adapter for git repositories

async = require 'async'
Git = require 'git-wrapper'

module.exports = class GitRepo
	git = new Git

	constructor: (@repo) ->
		@id = @repo

	@init: (config) -> new @ config.url

	parseBranches = (output) ->
		lines = output.split /\r\n?|\n/
		lines.pop() # last line will always be blank
		lines.map (line) ->
			[ref, branch] = line.split /\s+/, 2
			branch: branch, head: ref

	getBranches: (cb) ->
		async.waterfall [
			(cb) => git.exec 'ls-remote', [ '--heads', @repo ], cb
			(output, cb) -> cb null, parseBranches output
		], cb

	initLocalCopy: (localStore, branch, cb) ->
		git.exec 'clone', [ '--depth', '1', '--branch', branch, @repo, localStore ], cb

	updateLocalCopy: (localStore, cb) ->
		git.exec 'pull', cb
