# Data model for tracking builds for branches

logger = require '../logger'

mongoose = require 'mongoose'
async = require 'async'
Bacon = require 'baconjs'

BuildSchema = new mongoose.Schema
	revision:
		type: String
		required: true
	_branch:
		type: mongoose.Schema.Types.ObjectId
		ref: 'Branch'
		index: true
	creation:
		type: Date
		required: true
		default: Date.now
		index: true
	updated:
		type: Date
		required: true
		default: Date.now
	state:
		type: String
		required: true
		default: 'pending'
		enum: [ 'pending', 'building', 'success', 'failure', 'cancelled', 'skipped' ]

# (revision, branch) is unique as a compound index
BuildSchema.index { revision: 1, _branch: 1 }, { unique: true }

buildCreationBus = new Bacon.Bus
buildModificationBus = new Bacon.Bus

buildCreationBus.onValue (build) ->
	console.log 'build created!', build

buildModificationBus.onValue (build) ->
	console.log 'build modified!', build

BuildSchema.pre 'save', (next) ->
	@wasNew = @isNew
	@updated = Date.now()
	next()

BuildSchema.post 'save', ->
	if @wasNew
		buildCreationBus.push @
	else
		buildModificationBus.push @

BuildSchema.pre 'update', (next) ->
	@update $set: updated: Date.now()
	next()

BuildSchema.pre 'update', (next) ->
	logger.warn 'update call won\'t cause modification events'
	next()

BuildSchema.statics.creation = buildCreationBus.toEventStream()
BuildSchema.statics.modification = buildModificationBus.toEventStream()

## looks up a build on `branch` by `revision`, creating a new one if one doesn't exist
## callback = function(err, build, isNew)
BuildSchema.statics.findOrCreate = (branch, revision, cb) ->
	@findOne { _branch: branch, revision }, (err, build) =>
		return cb err if err?
		return cb null, build, false if build?
		@create { _branch: branch, revision }, (err, build) -> cb err, build, true

BuildSchema.statics.list = (branch, options, cb) ->
	queryOpts =
		limit: options?.perPage
		sort: created_at: -1
	queryOpts.skip = options.perPage * options.page if options?.perPage? and options?.page?
	@find(_branch: branch).setOptions(queryOpts).exec cb

BuildSchema.methods.latest = (branch, cb) ->
	@findOne { _branch: branch }, {}, { sort: created_at: -1 }, cb

module.exports = mongoose.model 'Build', BuildSchema
