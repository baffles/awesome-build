# Routes

express = require 'express'

is404 = (err) ->
	# we treat errors as 404 under certain circumstances
	/\bnot found\b|\bCast to ObjectId failed\b/.test err?.message

module.exports = (app) ->
	app.get '/', (req, res) ->
		res.render 'index', title: 'Home'

	api = express.Router()

	# api.use some-api

	## TEMP
	do (repo = require '../config/repo') ->
		# temporary direct interface to repo; this will be masked away later
		config = require '../config/config'
		fs = require 'fs'
		path = require 'path'
		RepoManager = require '../lib/repo/manager'
		manager = new RepoManager repo, path.join config.dataDirectory, "repo"

		api.get '/git-branches', (req, res) ->
			console.log "poll branches"
			repo.getBranches (err, branches) ->
				return res.status(500).json err if err?
				res.json branches

		api.get '/git-update', (req, res) ->
			branch = req.query.branch
			dir = manager.dir branch
			cb = (err, msg) ->
				return res.status(500).json err if err?
				res.send 'done'
			# this should probably go in repo manager, isntead of having separate clone/update functions
			if not fs.existsSync dir
				console.log "clone #{branch}"
				manager.clone branch, cb
			else
				console.log "update #{branch}"
				manager.update branch, cb
	## /TEMP

	api.use (err, req, res, next) ->
		return next() if is404 err
		console.error err.stack
		res.sendStatus 500

	api.use (req, res) ->
		res.sendStatus 404

	app.use '/api', api

	app.use (err, req, res, next) ->
		return next() if is404 err
		console.error(err.stack)
		res.status(500).render('500', { error: err.message })

	app.use (req, res) ->
		# assume 404 at this point, since no middleware responded and our error handler ignored the error
		res.status(404).render('404', { url: req.originalUrl, error: 'Not found', })
