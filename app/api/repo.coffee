# Repository action API router

express = require 'express'

repo = require '../controllers/repo'
router = express.Router()

router.route('/force-poll')
	.post(repo.forcePoll)

module.exports = router
