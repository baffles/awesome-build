# Branch API router

express = require 'express'

branch = require '../controllers/branch'
router = express.Router()

router.param 'branch-id', branch.load

router.route('/')
	.get(branch.list)

router.route('/:branch-id')
	.get(branch.get)

router.route('/:branch-id/state')
	.put(branch.setState)

router.use '/builds', require './build'

module.exports = router
