# Main configuration for server.

path = require 'path'
extend = (require 'util')._extend

env = process.env.NODE_ENV or 'development'

defaults =
	root: path.normalize "#{__dirname}/.."
	env: env
	config: 'config.yaml'

module.exports = extend defaults, require "./env/#{env}"
