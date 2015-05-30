# Build API router

express = require 'express'

build = require '../controllers/build'
router = express.Router()

router.param 'build-id', build.load

router.route('/')
	.get(build.list)

router.route('/latest')
	.get(build.latest)

router.route('/:build-id')
	.get(build.get)

module.exports = router
