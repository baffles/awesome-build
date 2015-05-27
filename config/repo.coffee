# Manages the configured repository.

config = require './config'

repoType = require "../lib/repo/#{config.repository.type}"

module.exports = repoType.init config.repository
