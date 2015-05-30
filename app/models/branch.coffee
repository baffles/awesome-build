# Data model for tracking a branch

logger = require '../logger'

mongoose = require 'mongoose'
async = require 'async'
Bacon = require 'baconjs'

BranchSchema = new mongoose.Schema
	name:
		type: String
		required: true
		unique: true
		index: unique: true
	state:
		type: String
		required: true
		default: 'active'
		enum: [ 'active', 'gone', 'ignored' ]

branchCreationBus = new Bacon.Bus
branchModificationBus = new Bacon.Bus

branchCreationBus.onValue (branch) ->
	console.log 'branch created!', branch

branchModificationBus.onValue (branch) ->
	console.log 'branch modified!', branch

BranchSchema.pre 'save', (next) ->
	@wasNew = @isNew
	next()

BranchSchema.post 'save', ->
	if @wasNew
		branchCreationBus.push @
	else
		branchModificationBus.push @

BranchSchema.pre 'update', (next) ->
	logger.warn 'update call won\'t cause modification events'
	next()

BranchSchema.statics.creation = branchCreationBus.toEventStream()
BranchSchema.statics.modification = branchModificationBus.toEventStream()
#TODO: bus for build modifications (so we can tell when something goes from pending to skipped)

BranchSchema.virtual('workFolder').get -> @_id

## looks up a branch by `name`, creating a new one if one doesn't exist
## callback = function(err, branch, isNew)
BranchSchema.statics.findOrCreate = (name, cb) ->
	@findOne { name }, (err, branch) =>
		return cb err if err?
		return cb null, branch, false if branch?
		@create { name }, (err, branch) -> cb err, branch, true

BranchSchema.statics.list = (options, cb) ->
	criteria = options.criteria ? {}
	@find(criteria).limit(options.perPage).skip(options.perPage * options.page).exec cb

module.exports = mongoose.model 'Branch', BranchSchema
