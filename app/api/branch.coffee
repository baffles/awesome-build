# Branch API router

express = require 'express'

branch = require '../controllers/branch'
router = express.Router()

router.param 'branch', branch.loadById

router.route('/')
	.get(branch.list)

router.route('/:branch')
	.get(branch.get)

router.route('/:branch/state')
	.put(branch.setState)

router.use '/:branch/build', require './build'

module.exports = router
