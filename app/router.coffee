# Main router for everything

express = require 'express'
logger = require './logger'

is404 = (err) ->
	# we treat errors as 404 under certain circumstances
	/\bnot found\b|\bCast to ObjectId failed\b/.test err?.message

appRouter = express.Router()
apiRouter = express.Router()

module.exports =
	app: appRouter
	api: apiRouter
	init: (app) ->
		appRouter.get '/', (req, res) ->
			res.render 'index', title: 'Home'

		appRouter.get '/stream-test', (req, res) ->
			res.send """
			<html>
			<head>
				<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
				<script>
					function subBranch(id, name) {
						console.log('subscribing to branch ' + name);

						var stream = new EventSource('/api/branch/' + id + '/build/stream');
						stream.addEventListener('created', function(e) {
							console.log('build created on branch ' + name, e.data);
						});
						stream.addEventListener('modified', function(e) {
							console.log('build modified on branch ' + name, e.data);
						});
					}

					/*$.ajax('/api/branch').done(function(branches) {
						branches.forEach(function(branch) { subBranch(branch._id, branch.name); });

						console.log('got branches; subscribing to branch updates');*/

						var branchStream = new EventSource('/api/branch/stream');
						branchStream.addEventListener('created', function(e) {
							var branch = JSON.parse(e.data);
							console.log('branch created', branch);
							//subBranch(branch._id, branch.name);
						});
						branchStream.addEventListener('modified', function(e) {
							console.log('branch modified', e.data);
						});
					/*});*/

					subBranch('556a46ef098c5fbc9fb2d77a', 'refs/heads/test4');
				</script>
			</head>
			<body>
			Look at console
			</body>
			</html>
			"""

		apiRouter.use '/branch', require './api/branch'
		apiRouter.use '/repo', require './api/repo'

		apiRouter.use (err, req, res, next) ->
			return next() if is404 err
			logger.error 'error serving API request', err
			res.sendStatus 500

		apiRouter.use (req, res) ->
			res.sendStatus 404

		app.use appRouter
		app.use '/api', apiRouter

		app.use (err, req, res, next) ->
			return next() if is404 err
			logger.error 'error serving request', err
			res.status(500).render('500', { error: err.message })

		app.use (req, res) ->
			# assume 404 at this point, since no middleware responded and our error handler ignored the error
			res.status(404).render('404', { url: req.originalUrl, error: 'Not found', })
