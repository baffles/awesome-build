# Manages local working copies of repositories

logger = require '../../config/logger'

async = require 'async'
md5 = require 'MD5'
fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'

Branch = require '../models/branch'
Build = require '../models/build'

module.exports = class RepoManager
	constructor: (@repo, @data) ->
		mkdirp.sync @data

	#id: (branch) -> md5 "#{@repo.id}!!#{branch}"
	#dir: (branch) -> path.join @data, @id branch
	dir: (branch) -> path.join @data, branch.workFolder

	### Polls the repository for branch changes ###
	poll: (cb) ->
		@repo.getBranches (err, branches) =>
			return cb err if err?

			# process each remote by updating or creating the branch record
			#TODO: only add builds if they don't already exist
			process = (branch, cb) =>
				async.waterfall [
					(cb) -> Branch.findOrCreate branch.branch, cb
					(_branch, isNew, cb) ->
						logger.debug "created branch #{branch.branch}" if isNew
						if _branch.state isnt 'ignored'
							async.waterfall [
								(cb) -> Build.findOrCreate _branch._id, branch.head, cb
								(_build, isNew, cb) ->
									logger.debug "created build #{_build.revision}" if isNew
									cb null, _branch
							], cb
						else
							cb null, _branch
				], cb

			async.waterfall [
				(cb) -> async.map branches, process, cb
				(branches, cb) ->
					# fetch any unmention branches
					seen = branches.map (branch) -> branch.name
					Branch.find { name: $nin: seen }, cb
				(goneBranches, cb) ->
					# mark the gone branches as 'gone'
					logger.debug "marking #{goneBranches.length} branches as gone"
					markAsGone = (branch, cb) ->
						branch.state = 'gone'
						branch.save cb
					async.each goneBranches, markAsGone, cb
			], (err) -> cb err

	### Makes available the latest for `branch`, calling `cb` with the working directory ###
	fetch: (branch, cb) ->
		#TODO: make this obey what's in the database
		dir = @dir branch
		async.waterfall [
			(cb) -> fs.exists dir, cb
			(exists, cb) =>
				if exists
					# just an update if it already exists
					@doUpdate dir, cb
				else
					@doClone branch, dir, cb
		], (err) ->
			return cb err if err?
			cb null, dir

	doClone: (branch, dir, cb) ->
		async.waterfall [
			(cb) -> mkdirp dir, cb
			(dir, cb) => @repo.initLocalCopy dir, branch, cb
		], cb

	doUpdate: (dir, cb) ->
		@repo.updateLocalCopy dir, cb
