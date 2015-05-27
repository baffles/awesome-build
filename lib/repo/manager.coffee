# Manages local working copies of repositories

async = require 'async'
md5 = require 'MD5'
mkdirp = require 'mkdirp'
path = require 'path'

module.exports = class RepoManager
	constructor: (@repo, @data) ->
		mkdirp.sync @data

	id: (branch) -> md5 "#{@repo.id}!!#{branch}"
	dir: (branch) -> path.join @data, @id branch

	clone: (branch, cb) ->
		dir = @dir branch
		async.waterfall [
			(cb) -> mkdirp dir, cb
			(dir, cb) => @repo.initLocalCopy dir, branch, cb
		], cb

	update: (branch, cb) ->
		@repo.updateLocalCopy @dir(branch), cb
