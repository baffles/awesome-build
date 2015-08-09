# Manages scheduling, updating, and running builds

Bacon = require 'baconjs'
logger = require '../logger'

Branch = require '../models/branch'
Build = require '../models/build'

###
when branch is enabled, we need to trigger a poll again to get the latest
when branch is disabled, we need to cancel any pending builds (let any running builds finish), marking them as skipped

we need to make sure only one instance of this runs
on startup, mark any building builds as pending again (they didn't finish). mark all except the latest pending build as skipped.

keep a state - for each enabled branch, keep current running build and on-deck build

as new builds are created, if it's newer than the on-deck build, swap it in and mark the on-deck as skipped. if no active build is going on that branch, queue the on-deck right away.

as build processes finish, queue up the on-deck for the finished branch, if there is one. then pump the queue.

build process starts by pending->building, runnign whatever commands, and when it finishes, updates the state again
###

class BuildManager
	constructor: ->
		# we're interested in all build events, we filter by build state
		buildEvents = Build.creation.merge Build.modification

		newBuilds = buildEvents.filter (build) ->
			switch build.state
				when 'pending' then true
				else false
		deadBuilds = buildEvents.filter (build) ->
			switch build.state
				when 'cancelled', 'skipped' then true
				else false

		newBuilds.onValue (build) -> console.log 'new build!', build
		deadBuilds.onValue (build) -> console.log 'dead build...', build

		# we also need to monitor branches, so we know which ones we should be building
		# our branch map property needs an initial state (load from DB) first
		# Bacon seems to re-bind the node callback if we pass it directly, so we wrap it
		initialBranches = Bacon.fromNodeCallback (cb) -> Branch.list {}, cb
		branchMap = initialBranches.flatMapLatest (branches) ->
			isEnabled = (state) ->
				switch state
					when 'active' then true
					else false

			initialBranchMap = do ->
				map = {}
				map[branch._id] = isEnabled branch.state for branch in branches
				map

			# set up a state machine to track branch events
			branchEvents = Branch.creation.merge Branch.modification
			Bacon.update initialBranchMap,
				[ Branch.creation ], (map, branch) ->
					map[branch._id] = isEnabled branch.state
					map
				[ Branch.modification ], (map, branch) ->
					map[branch._id] = isEnabled branch.state
					map

		branchMap.log 'got new branch map:'

module.exports = new BuildManager
